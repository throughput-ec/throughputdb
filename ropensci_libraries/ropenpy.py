import sys
from py2neo import Graph
import requests
import json
import re
from github import Github
from github import RateLimitExceededException
import time

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


headers = {'Accept': 'application/vnd.github.v3+json',
           'Authorization': 'token ' + gh_token[2]}

script_home = 'https://github.com/throughput-ec/' + \
              'throughputdb/blob/master/populate/case_study.Rmd'

gitendpoint = 'https://api.github.com/search/code'

ropensci = requests.get(link).json().get('packages')


def goodHit(query, text):
    """Check for expected query call in file content.

    Parameters
    ----------
    query : str
        Text string passed to the original GitHub code search query.
    text : list
        The File contents, including highlighted fragments.

    Returns
    -------
    type
        Description of returned object.

    """
    strings = query.split(" ")
    match = strings[0] + r'\(([^\)]*' + strings[1][:-1] + ')'
    check = list(map(lambda x: re.match(match, x.get('fragment')), text))
    output = not(all(matches is None for matches in check))
    return output


def callquery(g, query, silent=False):
    """Calls the GitHub API through the GitHub package.
    Probably better to pass the `g` object as well.

    Parameters
    ----------
    g : Github
        The GitHub session connection.
    query : string
        A query to pass to the GitHub code search API at
        https://developer.github.com/v3/search/
    silent : boolean
        Should a verbose response be returned?

    Returns
    -------
    set
        The set of all responses from the code search as a JSON string with
        keys `id`, `name`, `url`, `description` and `keywords`.

    """
    resset = set()
    left = g.get_rate_limit()
    if left.search.remaining < 5:
        reset = left.search.reset
        diff = int(reset.strftime('%s')) - int(time.mktime(time.gmtime()))
        if diff > 0:
            print('pausing . . for ' + str(diff) + 'sec')
            time.pause(diff)
    while True:
        try:
            results = g.search_code(query, highlight=True)
            break
        except RateLimitExceededException:
            delay = g.rate_limiting_resettime
            diff = delay - int(time.mktime(time.gmtime()))
            print("Hit error.  Waiting: 2mins")
            time.sleep(600)
    i = 0
    for sres in results:
        if goodHit(query, sres.text_matches):
            res = sres.repository
            left = g.get_rate_limit()
            if left.core.remaining < 100:
                reset = left.core.reset
                diff = int(reset.strftime('%s')) \
                    - int(time.mktime(time.gmtime()))
                if diff > 0:
                    print('pausing . . for ' + str(diff) + 'sec')
                    time.sleep(diff)
            if silent is False:
                print(str(i) + ' ' + res.full_name
                      + ' (remaining GitHub API calls: '
                      + str(left.core.remaining) + ')')
            repo = {'id': res.id,
                    'name': res.full_name,
                    'url': res.html_url,
                    'description': res.description,
                    'keywords': res.topics}
            i = i + 1
            resset.add(json.dumps(repo))
    return resset


def shortname(package):
    gh = re.compile(r'.*github.com\/(:?.*)')
    matcher = gh.match(pack.get('github')).group(1)
    return matcher


def repoinfo(g, package):
    matcher = shortname(package)
    repo = g.get_repo(matcher)
    return repo


def getRepo(g, pack):
    """Get repository information, with try/catch.

    Parameters
    ----------
    g : GitHub
        A Python GitHub object from `PyGithub`.
    pack : dict
        A dictionary object from the ROpenSci registry.

    Returns
    -------
    type
        An object of type `github.Repository.Repository`.

    """
    while True:
        try:
            repo = repoinfo(g, pack)
            break
        except RateLimitExceededException:
            time.sleep(120)
            continue
    annotation = "The GitHub repository uses the package " \
                 + pack.get('name') + " in a `library()` or `require()` call."
    parent = {'parentid': repo.id,
              'parentname': shortname(reponame),
              'parentdescription': repo.description,
              'parenturl': repo.html_url,
              'parentkeywords': str(repo.topics) + ',' + pack.get('keywords'),
              'annotation': annotation}
    parent['parentkeywords'] = parent.get('parentkeywords').split(',')
    if 'None' in parent.get('parentkeywords'):
        parent.get('parentkeywords').remove('None')
    return parent


for pack in ropensci:
    reponame = pack.get('github')
    parent = getRepo(g, pack)
    if parent['parentkeywords'] != ['']:
        keywordadd = {'id': parent['parentid'],
                      'keywords': parent['parentkeywords']}
        print("Adding keywords for parent repo")
        with open('cql/addkeywords.cql') as kwlink:
            silent = graph.run(kwlink.read(), keywordadd)
    query = pack.get('name') \
        + ') extension:R extension:Rmd'
    while True:
        try:
            libcall = callquery(g, 'library ' + query)
            break
        except RateLimitExceededException:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            time.sleep(600)
            continue
        while True:
            try:
                print("Unexpected error:", sys.exc_info()[0])
                print('Oops, broke for ' + parent.get('parentname')
                      + ' with require call.')
                reqcall = callquery(g, 'require ' + query)
                break
            except RateLimitExceededException:
                time.sleep(600)
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
