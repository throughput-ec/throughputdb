'''
**Add subjects and contacts**
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
from func.parsere3 import parsere3
import re

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

with open('./connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data)

tx = graph.begin()

re3api_short = "https://www.re3data.org/api/beta/repository/"

nodes = []

for repo in repositories:
    print("Working on " + str(repo['name']))
    check = graph.run("""
        MATCH (dc:dataCat {id: $id})
        WHERE (:SUBJECT)<-[:hasSubject]-(:ANNOTATION)-[:Target]->(dc)
        RETURN dc""", {'id': repo['id']}).data()
    if len(check) > 0:
        print("Skipped " + str(repo['name']))
    if len(check) == 0:
        uri = "https://www.re3data.org/api/beta/repository/" + repo['id']
        repodata = parsere3(uri)['r3d:re3data']['r3d:repository']
        if 'r3d:subject' in list(repodata):
            if type(repodata.get('r3d:subject')) is list:
                subjects = map(lambda x: {
                        'scheme': x.get('@subjectScheme'),
                        'subject': {'subjectid': int(re.match(r'\d+',
                                                     x.get('#text'))[0]),
                                    'subject': re.match(r'(?:\d*\s)([A-Za-z].*)',
                                                        x.get('#text'))[1]
                                    }
                    }, repodata.get('r3d:subject'))
            else:
                x = repodata.get('r3d:subject')
                subjects = [{
                    'scheme': x.get('@subjectScheme'),
                    'subject': {'subjectid': int(re.match(r'\d+',
                                                          x.get('#text'))[0]),
                                'subject': re.match(r'(?:\d*\s)([A-Za-z].*)',
                                                    x.get('#text'))[1]
                                }
                            }]
            node = {'id': repo.get('id'),
                    'subjects': list(subjects),
                    'contact': repodata.get('r3d:repositoryContact')}
            with open("cql/addSubjects.cql") as linker:
                silent = graph.run(linker.read(), node)
            nodes.append(node)
