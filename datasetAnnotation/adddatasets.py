import json
import re
import csv
import argparse
from py2neo import Graph
from os import listdir

parser = argparse.ArgumentParser(description='Add dataset information for a data resource to the Throughput Graph.')
parser.add_argument('-csv', nargs=1,
                    help='A flag to import a csv file.')

args = parser.parse_args()
print(args)

# with open('../.gitignore') as gi:
#     good = False
#     # This simply checks to see if you have a connection string in your repo.
#     # I use `strip` to remove whitespace/newlines.
#     for line in gi:
#         if line.strip() == "connect_remote.json":
#             good = True
#             break
#
# if good is False:
#     print("The connect_remote.json file is not in your .gitignore file. \
#            Please add it!")
#
# with open('../connect_remote.json') as f:
#     data = json.load(f)

#graph = Graph(**data[1])

#tx = graph.begin()

with open(args[0]) as csvfile:
    reader = csv.DictReader(csvfile, delimiter=',')
    header = reader.fieldnames
        print(header)
