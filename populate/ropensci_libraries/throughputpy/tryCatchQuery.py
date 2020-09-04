import sys
from github import RateLimitExceededException
from throughputpy.callquery import callquery
from time import sleep


def tryCatchQuery(g, parent, query):
    while True:
        try:
            libcall = callquery(g, query)
            break
        except RateLimitExceededException:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            sleep(120)
            continue
        except:
            print("Unexpected error:", sys.exc_info()[0])
            print('Oops, broke for ' + parent.get('parentname')
                  + ' with library call.')
            sleep(120)
            continue
    return libcall
