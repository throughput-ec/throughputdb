// Missing objects in the graph:

MATCH (a:ANNOTATION)-[]-(:MOTIVATION)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

MATCH (a:ANNOTATION)-[]-(:KEYWORD)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

MATCH (a:ANNOTATION)-[]-(:AGENT)
WHERE NOT (a)-[]-(:OBJECT)
RETURN COUNT(a)

// Multiple relationships between nodes.

MATCH p=(a:ANNOTATION)-[r]-(o:OBJECT)
WITH a, o, COUNT(r) AS hits
WHERE hits > 1
RETURN a, o, hits
LIMIT 10
