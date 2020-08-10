MATCH (mtv:MOTIVATION)
WITH DISTINCT t.term AS terms, COUNT(t) AS tcount
WHERE tcount > 1
MATCH (mtv:MOTIVATION)
WHERE t.term = terms
WITH t.term AS tterm, COLLECT(t) as termNodes
CALL apoc.refactor.mergeNodes(termNodes,
  {properties: {term:'discard', description:'discard', created:'discard'}}) YIELD node
RETURN node
