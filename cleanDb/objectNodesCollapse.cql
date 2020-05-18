// Checks:
MATCH (n:OBJECT)-[:isType]-(:TYPE {type:'schema:CodeRepository'})
WITH DISTINCT n.id AS id, COUNT(n) AS counts
WHERE counts > 1
MATCH (nt:OBJECT)
WHERE nt.id = id
WITH nt.id AS ids, COLLECT(nt) as objectNodes
CALL apoc.refactor.mergeNodes(objectNodes,
  {properties: {name:'discard', description: 'discard', id: 'discard',  url: 'discard', created:'discard'}}) YIELD node
RETURN node
