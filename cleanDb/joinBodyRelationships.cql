MATCH (a:ANNOTATION)-[r:Body]-(b)-[r1:Body]-(a)
WHERE r <> r1
WITH DISTINCT a, b
MATCH (a)-[rb:Body]-(b)
WITH a, b, COLLECT(rb) AS bodies
CALL apoc.refactor.mergeRelationships(bodies, {}) YIELD rel
RETURN rel;
