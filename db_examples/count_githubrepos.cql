// Number of added code repositories
MATCH (ty:TYPE {type:"schema:CodeRepository"})
MATCH (ocr:OBJECT)-[:isType]->(ty)
RETURN COUNT(DISTINCT ocr)

// Unique keywords (db associated, no longer there, moved to KEYWORDs)
MATCH (ty:TYPE {type: "schema:DataCatalog"})
MATCH (ty)<-[:isType]-(ob:OBJECT)
UNWIND SPLIT(ob.keywords, ",") AS uwky
RETURN COLLECT(distinct uwky)
