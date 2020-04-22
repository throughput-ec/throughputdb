from functools import reduce


def checkNode(graph, parentid):
    graphquery = """MATCH (n:OBJECT {id: $id})-[]-(:ANNOTATION)-[]-(o:OBJECT)-\
            [:isType]-(:TYPE {type:'schema:CodeRepository'})
            RETURN COUNT(o) AS repos"""
    silent = graph.run(graphquery, {'id': parentid}).data()
    links = reduce(lambda x, y: max(y.get('repos'), x.get('repos')), silent)
    if type(links) is dict:
        links = links.get('repos')
    return links
