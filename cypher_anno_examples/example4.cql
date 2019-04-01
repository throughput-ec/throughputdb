// Web Annotation Example 4:
// https://www.w3.org/TR/annotation-model/#segments-of-external-resources
//
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno4",
//   "type": "Annotation",
//   "body": "http://example.org/description1",
//   "target": {
//     "id": "http://example.com/image1#xywh=100,100,300,300",
//     "type": "Image",
//     "format": "image/jpeg"
//   }
// }

MERGE (ob:OBJECT {id:"http://example.org/description1"})
ON CREATE SET ob.created = timestamp()
CREATE (ob)<-[:Body]-(a:ANNOTATION {created:timestamp()})
MERGE (ot:OBJECT {id: "http://example.com/image1#xywh=100,100,300,300"})
ON CREATE SET ot.created=timestamp()
CREATE (t:TYPE {type: "Image"})<-[:isType]-(ot)<-[:Target]-(a);
