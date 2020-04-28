MATCH (o:OBJECT)-[:isType]-(:TYPE {type: 'schema:CodeRepository'})
WHERE exists(o.id)
WITH DISTINCT o.id AS ids, COUNT(o) AS idCount
MATCH (o:OBJECT)
WHERE o.id IN ids
WITH o.id AS id, COLLECT(o) as objectNodes
CALL apoc.refactor.mergeNodes(objectNodes,
  {properties: {properties:'discard', mergeRels:true}}) YIELD node
RETURN node
