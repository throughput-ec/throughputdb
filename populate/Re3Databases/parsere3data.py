'''
**Load data from the Re3Database **
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
import json
from func import parsere3

repositories = parsere3("https://www.re3data.org/api/v1/repositories")
repositories = repositories.get('list').get('repository')

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

re3api_short = "https://www.re3data.org/api/beta/repository/"
kws = set()

for repo in repositories:
    print("Working on " + str(repo['name']))
    uri = "https://www.re3data.org/api/beta/repository/" + repo['id']
    repodata = parsere3(uri)['r3d:re3data']['r3d:repository']
    node = {'id': repo.get('id'),
            'name': repodata.get('r3d:repositoryName').get('#text'),
            'url': repodata.get('r3d:repositoryURL'),
            'keywords': repodata.get('r3d:keyword'),
            'description': repodata.get('r3d:description').get('#text'),
            'languages': repodata.get('r3d:repositoryLanguage')}
    node = {key: ''
            if value is None else value for (key, value) in node.items()}
    if isinstance(node['keywords'], str):
        node['keywords'] = [node['keywords']]
    if isinstance(node['languages'], str):
        node['languages'] = [node['languages']]
    kws.update(node['keywords'])
    with open("cql/linkdbs.cql") as linker:
        silent = graph.run(linker.read(), node)
    with open("cql/addkeywords.cql") as keyworder:
        print(node['keywords'])
        silent = graph.run(keyworder.read(), node)
    with open("cql/addlanguage.cql") as langer:
        silent = graph.run(langer.read(), node)
