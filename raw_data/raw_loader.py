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

""" Breaks the language list into chunks delimited by %% """

langelem = f.text.split("\n%%\n")

for elm in langelem[1:]:

  """
      Find all the language labels:
      Split by the colon, keeping the colon as a property marker
  """
  things = [x for x in (re.split("\n*(.*:)", elm)) if x != '']

  isElem = list(map(lambda x: re.search(":", x) != None, things))

  """ Once we've found them, get the typeself.
      Because there are a number of subtypes in this definition we use the
      prefix 'lng_' to indicate they are all types of 'language' nodes. """

  type = "lng_" + re.sub("^ ", "", things[([c for c, v in enumerate(things) if things[c - 1] == 'Type:'][0])]
).upper()

  """ Then add all the node properties to a dictionary: """
  nodeProp = dict()

  for counter, v in enumerate(isElem):
    if counter < len(isElem) - 1:
      if isElem[counter] & (things[counter] != "Type:"):
        key = re.sub(":", "", things[counter]).lower()
        nodeProp[key] = re.sub("^ ", "", things[counter + 1])

  tx = graph.begin()
  tx.create(Node(type, **nodeProp))
  tx.commit()
