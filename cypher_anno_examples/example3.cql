// Web Annotation Example 3:
// https://www.w3.org/TR/annotation-model/#classes
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno3",
//   "type": "Annotation",
//   "body": {
//     "id": "http://example.org/video1",
//     "type": "Video"
//   },
//   "target": {
//     "id": "http://example.org/website1",
//     "type": "Text"
//   }
// }
// NOTE: The types will be created seperately.

UNWIND ["Dataset", "Image", "Video", "Sound", "Text", "TextualBody"] AS x
MERGE (t:TYPE {type: x})
ON CREATE SET t.created = timestamp();

MERGE (ob:OBJECT {id: "http://example.org/video1"})
ON CREATE SET ob.created = timestamp()
CREATE (:TYPE {type: "Video"})<-[:isType]-(ob)<-[:Body]- (a:ANNOTATION { created: timestamp() })
MERGE (ot:OBJECT {id: "http://example.org/website1"})
ON CREATE SET ot.created = timestamp()
CREATE (:TYPE {type: "Text"})<-[:isType]-(ot)<-[:Target]- (a);
