MATCH (aty:AGENTTYPE)
WITH DISTINCT t.type AS types, COUNT(t) AS tcount
WHERE tcount > 1
MATCH (aty:AGENTTYPE)
WHERE t.type = types
WITH t.type AS ttype, COLLECT(t) as typeNodes
CALL apoc.refactor.mergeNodes(typeNodes,
  {properties: {type:'discard', created:'discard'}}) YIELD node
RETURN node
