// Return the count of data repositories by database.
MATCH (tydc:TYPE {type:"schema:DataCatalog"})
MATCH (tycr:TYPE {type:"CodeRepository"})
MATCH (tydc)<-[:isType]-(odc:OBJECT)
MATCH (ocr:OBJECT)-[:isType]->(tycr)
MATCH (odc)<-[:Target]-(:ANNOTATION)-[:Target]->(ocr)
RETURN odc.name, COUNT(ocr.name)

// Return the count of links associated with a code repository:
MATCH (cr:TYPE {type:"schema:CodeRepository"})
MATCH (dc:TYPE {type:"schema:DataCatalog"})
MATCH (cr)<-[:isType]-(ocr:OBJECT)
MATCH (dc)<-[:isType]-(odc:OBJECT)
MATCH (odc)<-[:Target]-(an:ANNOTATION)
WHERE (an)-[:Target]->(ocr)
WITH DISTINCT ocr AS repos, SIZE(COLLECT(DISTINCT an)) AS anns
WHERE anns > 1
RETURN COUNT(repos)

// Return the count of data repositories with more than one link.
MATCH (tycr:TYPE {type:"CodeRepository"})
MATCH (ocr:OBJECT)-[:isType]->(tycr)
MATCH (an:ANNOTATION)-[:Target]->(ocr)<-[:Target]-(anb:ANNOTATION)
WHERE an <> anb
RETURN COUNT(p)

// Match articles to NSF Awards
MATCH (tyg:TYPE {type:'schema:Grant'})
MATCH (tya:TYPE {type:'schema:Article'})
MATCH (oa:OBJECT)-[:isType]->(tya)
MATCH (og:OBJECT)-[:isType]->(tyg)
MATCH p=(oa)<-[:Target]-(:ANNOTATION)-[:Target]->(og)-[:Funded_by]-()
RETURN p
LIMIT 30

// Match databases to Github Repos
MATCH (tyg:TYPE {type:'schema:DataCatalog'})
MATCH (tya:TYPE {type:'schema:CodeRepository'})
MATCH (oa:OBJECT)-[:isType]->(tya)
MATCH (og:OBJECT)-[:isType]->(tyg)
MATCH p=(oa)<-[:Target]-(:ANNOTATION)-[:Target]->(og)
RETURN p
LIMIT 300
