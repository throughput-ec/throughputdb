// Web Annotation Example 10:
// https://www.w3.org/TR/annotation-model/#choice-between-bodies
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno10",
//   "type": "Annotation",
//   "body": {
//     "type": "Choice",
//     "items": [
//       {
//         "id": "http://example.org/note1",
//         "language": "en"
//       },
//       {
//         "id": "http://example.org/note2",
//         "language": "fr"
//       }
//     ]
//   },
//   "target": "http://example.org/website1"
// }

MATCH (n) DETACH DELETE n;

WITH [
      {
        id: "http://example.org/note1",
        language: "en"
      },
      {
        id: "http://example.org/note2",
        language: "fr"
      }
    ] AS targets
UNWIND targets as x
MERGE (ob:OBJECT { id:x.id })-[:isLanguage]->(:LANGUAGE {language: x.language})
ON CREATE SET ob.created = timestamp()
WITH ob
CREATE (ob)<-[:Body]-(a:ANNOTATION {created:timestamp(), choice: True})
WITH a
MERGE (ot:OBJECT {id: "http://example.org/website1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
