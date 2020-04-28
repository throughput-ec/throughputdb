UNWIND ["Dataset", "Image", "Video", "Sound", "Text", "TextualBody", "schema:DataCatalog", "schema:Grant"] AS x
MERGE (t:TYPE {type: x})
ON CREATE SET t.created = timestamp();
