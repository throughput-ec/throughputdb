'''
-- GitHub Python scraper --

Linking to github repositories to find all repositories that contain code
related to the Re3Data databases.

This code hits the abuse detection mechanism, even with the pausing.
'''

from github import Github
from py2neo import Graph
from py2neo.data import Node, Relationship
import json
import random
import urllib
import requests
import re
import time

with open('../connect_remote.json') as f:
    data = json.load(f)

graph = Graph(**data)

tx = graph.begin()

# The use of the >>>!!!<<< is used to show deprecation apparently.
cypher = """MATCH (ob:OBJECT)-[:isType]-(:TYPE {type:'schema:DataCatalog'})
            WHERE NOT ob.description CONTAINS '>>>!!!<<<'
            RETURN ob"""
dbs = graph.run(cypher).data()

with open('gh.token') as f:
    token = json.load(f)

g = Github(**token)

gitadd = open('cql/github_linker.cql', mode="r")
git_cql = gitadd.read()

random.shuffle(dbs)

for db in dbs:
    time.sleep(10)
    print("Running graphs for", db['ob']['name'])
    repositories = []
    if len('"' + db['ob']['name'] + '" ' + db['ob']['url'] + ' in:file') > 127:
        searchString = '"' + db['ob']['name'] + '" in:file'
    else:
        searchString = '"' + db['ob']['name'] + '" ' + db['ob']['url'] + ' in:file'
    rate_limit = g.get_rate_limit()
    print("   There are " + str(rate_limit.search.remaining) + " calls to GitHub remaining.")
    if rate_limit.search.remaining < 2:
        print("   Rate limit reached, pausing for 10 seconds.")
        time.sleep(10)
    try:
        content_files = g.search_code(query=searchString)
        print("   Returning " + str(content_files.totalCount) + " results.")
    except:
        print("Sleeping for 30 seconds")
        time.sleep(30)
        g = Github(**token)
        next
    if content_files.totalCount == 1000:
        print("   **** There are more than 1000 results returned.  Skipping this element. ***")
        f = open('skipped_re3.txt', 'w+')
        f.write(searchString + "\r\n")
        f.close()
        time.sleep(10)
        continue
    for content in content_files:
        time.sleep(2)
        print("   There are " + str(rate_limit.search.remaining) + " calls to GitHub remaining.")
        repo = content.repository
        repElem = { 'ghid': repo.id,
                    'ghurl': repo.html_url,
                    'ghdescription': repo.description,
                    'ghname': repo.full_name ,
                    'otid':db['ob']['id'] }
        repositories.append(repElem)

    repositories = list({v['ghid']:v for v in repositories}.values())
    print("   Pushing information for " + str(len(repositories)) + " public repositories.")

    for rep in repositories:
        if rep['ghdescription'] is None:
            rep['ghdescription'] = ''
        test = graph.run("MATCH p=(ob1:OBJECT)-[]-(an:ANNOTATION)-[]-(ob2:OBJECT) WHERE ob1.id = {ghid} AND ob2.id = {otid} RETURN an", rep)
        if len(test.data()) == 0:
            print("    * Adding repository to the graph.")
            graph.run(git_cql, rep)
