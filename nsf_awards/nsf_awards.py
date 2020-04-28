import json
import re
from py2neo import Graph
from os import listdir
from awardpy.awardUnZip import awardUnZip

with open('../.gitignore') as gi:
    good = False
    # This simply checks to see if you have a connection string in your repo.
    # I use `strip` to remove whitespace/newlines.
    for line in gi:
        if line.strip() == "connect_remote.json":
            good = True
            break

if good is False:
    print("The connect_remote.json file is not in your .gitignore file. \
           Please add it!")

with open('../connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data[1])

tx = graph.begin()


def emptyNone(val):
    for k in val.keys():
        if type(val[k]) is list:
            val[k] = list(map(lambda x: emptyNone(x), val[k]))
        if type(val[k]) is dict:
            emptyNone(val[k])
        else:
            if val[k] is None:
                if re.search('Date', k) is not None:
                    val[k] = '0/0/0'
                else:
                    val[k] = ''
    return val


# Read the awards file directory:
awards = listdir('data/input/awards')

for i in awards:
    awardOutput = awardUnZip('data/input/awards/' + i)
    print("Unzipped '" + i + "' -- A total of "
          + str(len(awardOutput)) + " to run.")
    for j in awardOutput:
        print("Running award " + j.get('AwardID'))
        for dt in j.keys():
            if re.search('Date', dt) is not None:
                if j[dt] is None:
                    j[dt] = "0/0/0"
        j = emptyNone(j)
        with open('cql/addAward.cql') as file:
            silent = graph.run(file.read(), j)
        with open('cql/awardInstitution.cql') as file:
            silent = graph.run(file.read(), j)
        with open('cql/awardDates.cql') as file:
            silent = graph.run(file.read(), j)
        with open('cql/awardPeople.cql') as file:
            silent = graph.run(file.read(), j)
