// Web Annotation Example 13:
// https://www.w3.org/TR/annotation-model/#intended-audience
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno13",
//   "type": "Annotation",
//   "audience": {
//     "id": "http://example.edu/roles/teacher",
//     "type": "schema:EducationalAudience",
//     "schema:educationalRole": "teacher"
//   },
//   "body": "http://example.net/classnotes1",
//   "target": "http://example.com/textbook1"
// }
// NOTE: Sticking all the audience stuff into the Audience role right now.

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { id:"http://example.net/classnotes1"})
ON CREATE SET ob.created = timestamp()
WITH ob
MERGE (a:ANNOTATION {created: timestamp()})-[:Body]->(ob)
WITH a
CREATE (a)-[:hasAudience]->(au:AUDIENCE {id: "http://example.edu/roles/teacher",
                                type: "schema:EducationalAudience",
                                role: "schema:educationalRole:teacher"})
MERGE (ot:OBJECT {id: "http://example.com/textbook1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
