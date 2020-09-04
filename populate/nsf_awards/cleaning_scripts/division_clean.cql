MATCH (p:Division)
WITH DISTINCT p.code AS codes, collect(p) as nodes
CALL apoc.refactor.mergeNodes(nodes, {properties: {name:'combine', code:'discard'}}) YIELD node
RETURN node;

MATCH (p:Program)
WITH DISTINCT p.Code AS codes, collect(p) as nodes
CALL apoc.refactor.mergeNodes(nodes, {properties: {Text:'combine', Code:'discard'}}) YIELD node
RETURN node;

MATCH (i:Institution)
WITH DISTINCT i.Name AS instname, collect(i) as nodes
WHERE size(nodes) > 1
RETURN instname, nodes


MATCH (a:AGENT)-[afw:affiliatedWith]->(i:Institution)
WITH DISTINCT a.name AS name, a.email AS email, i.name AS inst, collect(afw) as rels
WHERE NOT name CONTAINS ("AVAILABLE")
WITH name, email, inst, rels
CALL apoc.refactor.mergeRelationships(rels,{properties:"combine"}) YIELD rel
RETURN rel


// Takes a while.  All name, email, institution combinations get combined.
MATCH (a:AGENT)-[:affiliatedWith]->(i:Institution)
WITH DISTINCT a.name AS name, a.email AS email, i.name AS inst, collect(a) as nodes
WHERE NOT name CONTAINS ("AVAILABLE") AND size(nodes) = 2
WITH name, email, inst, nodes LIMIT 1
CALL apoc.refactor.mergeNodes(nodes, {properties: 'discard', mergeRels:true}) YIELD node
RETURN "none";
