MATCH (mtv:MOTIVATION)
WITH DISTINCT mtv.term AS terms, COUNT(mtv) AS tcount
WHERE tcount > 1
MATCH (mtv:MOTIVATION)
WHERE mtv.term = terms
WITH mtv.term AS tterm, COLLECT(mtv) as termNodes
CALL apoc.refactor.mergeNodes(termNodes,
  {properties: {term:'discard', description:'discard', created:'discard'}}) YIELD node
RETURN node;

MATCH (mtv:MOTIVATION)-[:hasMotivation]-(a:ANNOTATION)
WITH DISTINCT a, mtv
MATCH (a)-[rb:hasMotivation]-(mtv)
WITH a, mtv, COLLECT(rb) AS motives
CALL apoc.refactor.mergeRelationships(motives, {}) YIELD rel
RETURN rel;
