// Web Annotation Example 6:
// https://www.w3.org/TR/annotation-model/#string-body
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno6",
//   "type": "Annotation",
//   "bodyValue": "Comment text",
//   "target": "http://example.org/target1"
// }

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { bodyValue: "Comment text" })
ON CREATE SET ob.created = timestamp()
CREATE (ob)<-[:Body]-(a:ANNOTATION {created:timestamp()})
MERGE (ot:OBJECT {id:"http://example.org/target1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a);
