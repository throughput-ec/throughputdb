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
