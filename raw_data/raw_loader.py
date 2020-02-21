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

graph = Graph(**data[1])

tx = graph.begin()

""" Some simple vocabularies and node types: """
print("Adding Accessibility Nodes")
with open("accessibilityFeatures.cql") as ascfeat:
    graph.run(ascfeat.read())

print("Adding Agent Nodes")
with open("agents.cql") as agents:
    graph.run(agents.read())

print("Adding Audience Nodes")
with open("audiences.cql") as aud:
    graph.run(aud.read())

print("Adding Motivation Nodes")
with open("motivation.cql") as motive:
    graph.run(motive.read())

print("Adding Type Nodes")
with open("type.cql") as type:
    graph.run(type.read())

"""
   Language is more complicated - There is a defined list available on the web:
"""

print("Adding Language Nodes")
link = "https://raw.githubusercontent.com/maikudou/iso639-js/master/iso639-3_living.json"
f = requests.get(link).json()

for key in f:
  elm = f[key]
  elm['code'] = key
  tx = graph.begin()
  tx.merge(Node("LANGUAGE", **elm))
  tx.commit()

'''
Remove duplicate nodes:
MATCH (g:LANGUAGE)
WITH g.part1 as id, collect(g) AS nodes
WHERE size(nodes) >  1
FOREACH (g in tail(nodes) | DELETE g)
'''
