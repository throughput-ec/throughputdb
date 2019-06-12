'''
-- GitHub Python scraper --

Linking to github repositories to find all repositories that contain code
related to the Re3Data databases.

'''

from github import Github
from py2neo import Graph
from py2neo.data import Node, Relationship
import json
import urllib
import requests
import re
import time

with open('../connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data)

tx = graph.begin()

with open('gh.token') as f:
    token = f.readlines()

# The use of the >>>!!!<<< is used to show deprecation apparently.
cypher = """MATCH (ob:OBJECT)-[:isType]-(:TYPE {type:'schema:DataCatalog'})
            WHERE NOT ob.description CONTAINS '>>>!!!<<<'
            RETURN ob"""
dbs = graph.run(cypher).data()

with open(gh.token) as f:
    token = json.load(f)

g = Github(**token)

gitadd = open('cql/github_linker.cql', mode="r")
git_cql = gitadd.read()

for db in dbs:
    time.sleep(8)
    print("Running graphs for", db['ob']['name'])
    try:
        repositories = g.search_repositories(query=db['ob']['name'])
        for rep in repositories:
            rep_info = { 'ghid': rep.id, 'ghurl': rep.html_url, 'ghdescription': rep.description, 'ghname': rep.name , 'otid':db['ob']['id'] }
            if rep_info['ghdescription'] is None:
                rep_info['ghdescription'] = ''
            test = graph.run("MATCH p=(ob1:OBJECT)-[]-(an:ANNOTATION)-[]-(ob2:OBJECT) WHERE ob1.id = {ghid} AND ob2.id = {otid} RETURN an", rep_info)
            if len(test.data()) == 0:
                graph.run(git_cql, rep_info)
    except:
        continue
