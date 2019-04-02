// Web Annotation Example 11:
// https://www.w3.org/TR/annotation-model/#lifecycle-information
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno11",
//   "type": "Annotation",
//   "creator": "http://example.org/user1",
//   "created": "2015-01-28T12:00:00Z",
//   "modified": "2015-01-29T09:00:00Z",
//   "generator": "http://example.org/client1",
//   "generated": "2015-02-04T12:00:00Z",
//   "body": {
//     "id": "http://example.net/review1",
//     "creator": "http://example.net/user2",
//     "created": "2014-06-02T17:00:00Z"
//   },
//   "target": "http://example.com/restaurant1"
// }
// How do we know that the information about the body creator is authoritative?
// Or is this information added by the user?  This rendering of the example
// Assumes that the authorship information is authoritative and not an annotation.

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { id:"http://example.net/review1"})
ON CREATE SET ob.created = timestamp()
WITH ob
MERGE (a:ANNOTATION {created: timestamp()})-[:Body]->(ob)<-[:Created {created: "2014-06-02T17:00:00Z"}]-(:AGENT {agent: "http://example.net/user2"})
WITH a
CREATE (a)<-[:Created {created: "2015-01-28T12:00:00Z", modified: "2015-01-29T09:00:00Z"}]-(:AGENT {agent:"http://example.org/user1"})
CREATE (a)<-[:Generated {generated: "2015-02-04T12:00:00Z"}]-(:AGENT {agent:"http://example.org/client1"})
MERGE (ot:OBJECT {id: "http://example.com/restaurant1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
