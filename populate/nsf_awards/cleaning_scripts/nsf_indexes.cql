CREATE INDEX awardno
FOR (n:OBJECT)
ON (n.AwardID)

CREATE INDEX yearKey
FOR (n:Year)
ON (n.Year)

CALL db.index.fulltext.createNodeIndex("abstracts",["OBJECT"],["name", "description"])


// Merging awards by name:
CALL db.index.fulltext.queryNodes("abstracts", "Neotoma") YIELD node
WITH node
MATCH (y:Year)-[:Year_Started]-(node)-[:isType]-(:TYPE {type:"schema:Grant"})
WITH DISTINCT tolower(node.name) AS name, y, COLLECT(node) as nodes
RETURN name, y, size(nodes)
Order by name
