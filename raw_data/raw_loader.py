'''
**Load neo4j data **
There is an assumption here that a json file exists with the
connection data for the database.  This file is in the ``.gitignore`
by default (or should be).

NOTE: This requires the inclusion of a json file in the base directory called
connect_remote.json that uses the format:

{
  "user": "neo4j",
  "password": "neo4j",
  "host": "localhost",
  "port": 7687
}

Please ensure that this file is included in the .gitignore file.
'''

from py2neo import Graph
from py2neo.data import Node, Relationship
import json
import urllib
import requests
import re

with open('../.gitignore') as gi:
    good = False
    # This simply checks to see if you have a connection string in your repo.
    # I use `strip` to remove whitespace/newlines.
    for line in gi:
        if line.strip() == "connect_remote.json":
            good = True
            break

if good is False:
    print("The connect_remote.json file is not in your .gitignore file.  Please add it!")

with open('../connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data)

tx = graph.begin()

""" Some simple vocabularies and node types: """
with open("accessibilityFeatures.cql") as ascfeat:
    graph.run(ascfeat.read())

with open("agents.cql") as agents:
    graph.run(agents.read())

with open("audiences.cql") as aud:
    graph.run(aud.read())

with open("motivation.cql") as motive:
    graph.run(motive.read())

with open("type.cql") as type:
    graph.run(type.read())

""" Language is more complicated - There is a defined list available on the web: """
print("Adding Language Nodes")
link = "https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry"
f = requests.get(link)

langelem = f.text.split("%%")
elements = list(map(lambda x: x.split("\n"), langelem))

for elm in elements:
  print("  * " + str(elm))
  tx = graph.begin()
  empty = [i for i, x in enumerate(elm) if x == '']
  if len(elm) > 2:
      for j in reversed(empty):
        elm.pop(j)
      things = list(map(lambda x: x.split(": "), elm))
      typeIdx = list(map(lambda x: x[0] == "Type", things)).index(True)
      type = things[typeIdx][1].upper()
      things.pop(typeIdx)
      print("    * " + str(things))
      elmDict = dict(things)
      elmDict = {k.lower(): v for k, v in elmDict.items()}
      elmDict = {k.lower(): v.strip() for k, v in elmDict.items()}
      print("    * " + type + " " + str(elmDict))
      tx.create(Node(type, **elmDict))
      tx.commit()
