MATCH (:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)
MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)
WITH ocr, odc
MATCH p = (odc)-[]-(:ANNOTATION)-[]-(ocr)-[]-(:ANNOTATION)-[]-(odc)
RETURN COUNT(p)

MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)-[]-(:ANNOTATION)-(ocr:OBJECT)-[:isType]-(:TYPE {type:"CodeRepository"})
MATCH p = (odc)-[]-(:ANNOTATION)-[]-(ocr)
RETURN odc.name, ocr.name, COUNT(ocr.name)
