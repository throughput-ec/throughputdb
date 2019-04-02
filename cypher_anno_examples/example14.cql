// Web Annotation Example 13:
// https://www.w3.org/TR/annotation-model/#accessibility-of-content
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno14",
//   "type": "Annotation",
//   "motivation": "commenting",
//   "body": "http://example.net/comment1",
//   "target": {
//     "id": "http://example.com/video1",
//     "type": "Video",
//     "accessibility": "captions"
//   }
// }

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { id:"http://example.net/comment1"})
ON CREATE SET ob.created = timestamp()
WITH ob
MATCH (mo:MOTIVATION {
  term: "commenting",
  type: "Instance",
  description: "The motivation for when the user intends to comment about the Target. For example to provide a commentary about a particular PDF document."
})
WITH ob, mo
MERGE (mo)<-[:isMotivated]-(a:ANNOTATION {created: timestamp()})-[:Body]->(ob)
WITH a
MERGE (ot:OBJECT { id: "http://example.com/video1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
WITH ot
MERGE (:TYPE {type:"Video"})<-[:isType]-(ot)-[:isAccessible]->(:ACCESSIBILITYFEATURE {feature: "captions"})
