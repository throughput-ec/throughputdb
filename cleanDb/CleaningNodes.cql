// Check all the node types:
CALL apoc.meta.stats() YIELD labels
RETURN labels

// If there's anything going on with the node counts:
MATCH (t:MOTIVATION)
WITH DISTINCT t.type AS types, COUNT(t) AS tcount
WHERE tcount > 1
MATCH (t:MOTIVATION)
WHERE t.type IN types
WITH t.type AS ttype, COLLECT(t) as typeNodes
CALL apoc.refactor.mergeNodes(typeNodes,
  {properties: 'combine'}) YIELD node
RETURN node

// There's an outstanding issue with capitalization of institution names.

// Clean duplicate relationships.
match (s)-[r]->(e)
with s, e, type(r) as typ, tail(collect(r)) as coll
WHERE size(coll) > 0
FOREACH(x IN coll | DELETE x)

// If there's anything going on with the node counts:
MATCH (k:KEYWORD)
WITH DISTINCT t.keyword AS kw, COUNT(kw) AS kwcount
WHERE kwcount > 1
MATCH (k:KEYWORD)
WHERE k.keyword IN keywords
WITH k.keyword AS kwds, COLLECT(k) as kwNodes
CALL apoc.refactor.mergeNodes(kwNodes,
  {properties: 'combine'}) YIELD node
RETURN node
