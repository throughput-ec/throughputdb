// Web Annotation Example 9:
// https://www.w3.org/TR/annotation-model/#string-body
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno9",
//   "type": "Annotation",
//   "body": [
//     "http://example.org/description1",
//     {
//       "type": "TextualBody",
//       "value": "tag1"
//     }
//   ],
//   "target": [
//     "http://example.org/image1",
//     "http://example.org/image2"
//   ]
// }

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { id:"http://example.org/description1", value: "tag1" })
ON CREATE SET ob.created = timestamp()
WITH ob
MATCH (ty:TYPE {type: "TextualBody"})
CREATE (ty)<-[:isType]-(ob)<-[:Body]-(a:ANNOTATION {created:timestamp()})
WITH a
UNWIND ["http://example.org/image1", "http://example.org/image2"] AS x
MERGE (ot:OBJECT {id: x})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
