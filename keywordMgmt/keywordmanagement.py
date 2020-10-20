import re
from nltk.corpus import wordnet
from py2neo import Graph
import json

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

graph = Graph(**data)

tx = graph.begin()

query = """MATCH (kw:KEYWORD)
           RETURN DISTINCT kw.keyword AS keyword"""

oldQuery = """MATCH (ob)-[]-(:ANNOTATION)-[:hasKeyword]->(kw:KEYWORD)
              RETURN ob.id AS id, COLLECT(DISTINCT kw.keyword) AS keywords"""

result = graph.run(query).data()

# First, find a list of all synonyms using wordnet.
# Then, parse the set of lists for any terms that share synonyms.

for term in result:
    wordset = wordnet.synsets(re.sub('-', ' ', term['keyword']))
    term['synonym'] = []
    for syn in wordset:
        for lemma in syn.lemmas():
            term['synonym'].append(lemma.name().lower())
        term['synonym'].append(term['keyword'])
        term['synonym'] = list(set(term['synonym']))
    print('We have found ' + str(len(term['synonym']))
          + ' synonyms for ' + term['keyword'])

for term in result:
    # Okay, now we run the graph.
    inputs = {'kwIn': term['keyword'],
              'term': list(filter(lambda x: x != term['keyword'],
                                  term['synonym']))}
    silent = graph.run(open('cql/connect_kw.cql').read(), inputs)
    print('.done.')
