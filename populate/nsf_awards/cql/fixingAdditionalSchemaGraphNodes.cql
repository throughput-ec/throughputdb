MERGE (og:TYPE {type:'schema:Grant'})
WITH og
MATCH (a:OBJECT)-[r:isType]-(n:TYPE {type:'schema:Grant'})
WITH a, n, r, og
DELETE r, n
MERGE (a)-[:isType]->(og)

// Added 1 label, created 187628 nodes, deleted 187627 nodes, set 1 property, deleted 187627 relationships, created 187627 relationships, completed after 15641 ms.

MATCH (n:OBJECT) WHERE EXISTS(n.AwardID)
MATCH (og:TYPE {type:'schema:Grant'})
WITH n, og
CREATE (n)-[:isType]->(og)
