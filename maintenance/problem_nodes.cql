// Missing objects in the graph:
MATCH (a:ANNOTATION)-[]-(:MOTIVATION)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

MATCH (a:ANNOTATION)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

MATCH (a:OBJECT)
WHERE NOT (a)-[]-()
RETURN COUNT(a)

MATCH (a:ANNOTATION)-[]-(:KEYWORD)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

MATCH (a:ANNOTATION)-[]-(:AGENT)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

// Multiple relationships between nodes.

MATCH p=(a:ANNOTATION)-[r]-(o:OBJECT)
WITH DISTINCT a, o, COUNT(r) AS hits
WHERE hits > 1
RETURN a, o, hits
LIMIT 10

// Self-referencing relationships.
MATCH (a)
WITH a
MATCH (a)-[b]-(a)
RETURN a, b
LIMIT 5

// URLs that don't use https.
MATCH (o:OBJECT)-[:isType]->(:TYPE {type:'schema:CodeRepository'})
WHERE NOT o.url CONTAINS('https')
RETURN COUNT(o)
