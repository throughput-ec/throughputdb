// Checks:
MATCH (n:OBJECT)-[:isType]-(:TYPE {type:'schema:CodeRepository'})
WITH DISTINCT n.id AS id, COUNT(n) AS counts
WHERE counts > 1
UNWIND id as minid
MATCH (nt:OBJECT)
WHERE nt.id = minid
WITH COLLECT(nt) as objectNodes
CALL apoc.refactor.mergeNodes(objectNodes,
  {properties:"discard", mergeRels:true}) YIELD node
RETURN COLLECT(node);
