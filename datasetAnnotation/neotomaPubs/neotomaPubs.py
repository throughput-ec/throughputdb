import json
import csv
import re
from py2neo import Graph

with open('../../.gitignore') as gi:
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

with open('../../connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data)

tx = graph.begin()
neodois = []

with open('neotoma_Publications.csv') as csvfile:
    reader = csv.DictReader(csvfile, delimiter=',')
    header = reader.fieldnames
    for rows in reader:
        search = re.search(r'10.\d{4,9}/.*$', rows['doi'])
        if search is None:
            continue
        else:
            neodois.append({'dsid': rows['datasetid'], 'doi': search[0]})

match = '''MATCH (ar:Article)
           RETURN ar.id AS doi'''

paperdois = graph.run(match, rows).data()

paperdoiset = list(set([i['doi'] for i in paperdois]))

for dois in neodois:
    if dois['doi'] in paperdoiset:
        print("Got match.")
        testMatch = """MATCH (dsty:TYPE {type:'Dataset'})
                       MATCH (ob)-[:isType]->(dsty)
                       MATCH (ob)<-[:Target]-(:ANNOTATION)-[:Target]->(ar:Article)
                       WHERE ob.id = $dsid
                       RETURN COUNT(ob) AS ct"""
        counts = graph.run(testMatch, dois).data()[0]['ct']
        if counts == 0:
            with open("cql/addArticleDataset.cql") as linkart:
                silent = graph.run(linkart.read(), dois)
        else:
            print("\tAlready added.")
