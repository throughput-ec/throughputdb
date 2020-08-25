MATCH (mtv:MOTIVATION)
WITH DISTINCT mtv.term AS terms, COUNT(mtv) AS tcount
WHERE tcount > 1
MATCH (mtv:MOTIVATION)
WHERE mtv.term = terms
WITH mtv.term AS tterm, COLLECT(mtv) as termNodes
CALL apoc.refactor.mergeNodes(termNodes,
  {properties: {term:'discard', description:'discard', created:'discard'}}) YIELD node
RETURN node
