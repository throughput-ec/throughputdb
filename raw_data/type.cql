UNWIND ["Dataset", "Image", "Video", "Sound", "Text", "TextualBody"] AS x
MERGE (t:TYPE {type: x})
ON CREATE SET t.created = timestamp();
