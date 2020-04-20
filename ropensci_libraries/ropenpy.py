import sys
from py2neo import Graph
import requests
import json
from github import Github
from github import RateLimitExceededException
import time
from throughputpy import getRepo
from throughputpy import callquery

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

with open('../gh.token') as f:
    gh_token = f.read().splitlines()

g = Github(gh_token[2])

graph = Graph(**data[1])

tx = graph.begin()

# load registry:
link = "https://raw.githubusercontent.com/ropensci/roregistry/" + \
        "gh-pages/registry.json"

script_home = 'https://github.com/throughput-ec/' + \
              'throughputdb/blob/master/populate/case_study.Rmd'

ropensci = requests.get(link).json().get('packages')

for pack in ropensci:
    reponame = pack.get('github')
    parent = getRepo.getRepo(g, reponame, pack)
    if parent['parentkeywords'] != ['']:
        keywordadd = {'id': parent['parentid'],
                      'keywords': parent['parentkeywords']}
        print("Adding keywords for " + reponame)
        with open('cql/addkeywords.cql') as kwlink:
            silent = graph.run(kwlink.read(), keywordadd)
    query = pack.get('name') \
        + ' extension:R extension:Rmd'
    while True:
        try:
            libcall = callquery.callquery(g, 'library ' + query)
            break
        except RateLimitExceededException:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            time.sleep(120)
            continue
        except:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            time.sleep(120)
            continue
    while True:
        try:
            reqcall = callquery.callquery(g, 'require ' + query)
            break
        except RateLimitExceededException:
            time.sleep(120)
            continue
        except:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            time.sleep(120)
            continue
    print("Done getting repositories")
    allrepos = libcall | reqcall
    print("Called a total of " + str(len(allrepos)) + " repositories.")
    if len(allrepos) > 0:
        for childrepo in allrepos:
            reposet = json.loads(childrepo)
            reposet.update(parent)
            print("Adding " + str(reposet['name']))
            if reposet.get('name') == parent.get('parentname'):
                print("Skipping link to same parent repository.")
            else:
                print("")
                print(reposet)
                reposet = {key: ''
                           if value is None else value
                           for (key, value) in reposet.items()}
                reposet['keywords'] = reposet['keywords'].split(',')
                with open('cql/link_ropensci.cql') as linking:
                    silent = graph.run(linking.read(), reposet)
                if reposet['keywords'] != ['']:
                    keywordadd = {'id': reposet['id'],
                                  'keywords': reposet['keywords']}
                    print("Adding keywords for child repo")
                    with open('cql/addkeywords.cql') as kwlink:
                        silent = graph.run(kwlink.read(), keywordadd)
