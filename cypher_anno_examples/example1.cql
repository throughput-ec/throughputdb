// Web Annotation Example 1:
// https://www.w3.org/TR/annotation-model/#annotations
// {
//  "@context": "http://www.w3.org/ns/anno.jsonld",
//  "id": "http://example.org/anno1",
//  "type": "Annotation",
//  "body": "http://example.org/post1",
//  "target": "http://example.com/page1"
// }

MERGE (ob:OBJECT {id: "http://example.org/post1"})
ON CREATE SET ob.created = timestamp()
CREATE (ob)<-[b:Body]-(a:ANNOTATION { created: timestamp() })
MERGE (ot:OBJECT {id: "http://example.com/page1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[t:Target]-(a)
