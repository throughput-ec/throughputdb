// Number of added code repositories
MATCH (:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)
RETURN COUNT(DISTINCT ocr)

// Unique keywords
MATCH (:TYPE {type: "schema:DataCatalog"})-[:isType]-(ob:OBJECT)
UNWIND SPLIT(ob.keywords, ",") AS uwky
RETURN COLLECT(distinct uwky)
