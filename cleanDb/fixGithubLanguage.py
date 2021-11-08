''' 
There were a set of "language" meta tags in the github repos that were not
structured as proper JSON dictionaries.  This script is intended as a one-off
script to fix that.

The script executes a query to pull all code repositories with `meta` tags, and then
processes them, looking for a `languages` tag that is not `json.load`ed as a `dict`.
Once it finds those there's a bit of testing to make sure they are what we expect, and
then it pulls each dict in the list into a single dict, and `SET`s it back into the
database.
'''

from py2neo import Graph
import json
import os

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

if os.path.exists('../connect_remote.json'):
    with open('../connect_remote.json') as f:
        data = json.load(f)
else:
    raise Exception("No connection file exists.")


# Begin the graph connection.
graph = Graph(**data)
tx = graph.begin()

# We want to open up the github repos and find all the ones with "Python" as a language
cypher = """MATCH (n:codeRepo)
            WHERE EXISTS(n.meta)
            WITH n AS metaNodes
            WITH metaNodes
            WHERE EXISTS(apoc.convert.fromJsonMap(metaNodes.meta).languages)
            RETURN properties(metaNodes) AS repo"""

print("Querying Python Repos:")
pyRepos = graph.run(cypher).data()

#  This will SET the property.  Needs to RETURN otherwise py2neo chokes.
cypherSet = """MATCH (n:codeRepo)
               WHERE n.id = $id
               SET n.meta = $newmeta
               RETURN 1"""

# For each repository, load the meta, check to make sure it's a string
# Then take the dicts in the list and smash them into a single dict.
for i in pyRepos:
    meta = json.loads(i['repo']['meta'])
    if type(meta['languages']) is not dict and len(meta['languages']) > 0:
        languages = json.loads(meta['languages'])
        if type(languages) is list:
            newlang = {}
            for j in languages:
                if len(j) == 1:
                    key = list(j.keys())[0]
                    newlang[key] = j[key]
                if len(j) > 1:
                    break
            meta['languages'] = newlang
            print('Updating ' + meta['name'])
            uploader = {"id": meta['id'], "newmeta": json.dumps(meta)}
            silent = graph.run(cypherSet, parameters = uploader)
