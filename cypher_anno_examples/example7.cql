// Web Annotation Example 7:
// https://www.w3.org/TR/annotation-model/#string-body
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno7",
//   "type": "Annotation",
//   "body": {
//     "type": "TextualBody",
//     "value": "Comment text",
//     "format": "text/plain"
//   },
//   "target": "http://example.org/target1"
// }

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { value: "Comment text", format: "text/plain" })
ON CREATE SET ob.created = timestamp()
CREATE (:TYPE {type: "TextualBody"})<-[:isType]-(ob)<-[:Body]-(a:ANNOTATION {created:timestamp()})
MERGE (ot:OBJECT {id:"http://example.org/target1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a);
