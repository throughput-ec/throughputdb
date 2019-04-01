// Web Annotation Example 5:
// https://www.w3.org/TR/annotation-model/#embedded-textual-body
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno5",
//   "type": "Annotation",
//   "body": {
//     "type" : "TextualBody",
//     "value" : "<p>j'adore !</p>",
//     "format" : "text/html",
//     "language" : "fr"
//   },
//   "target": "http://example.org/photo1"
// }

MATCH (n) DETACH DELETE n;

// NOTE: Languages will be created seperately.
//       Formats should also be created seperately
UNWIND ["en", "fr", "de", "da", "yue"] AS x
MERGE (la:LANGUAGE {language: x})
ON CREATE SET la.created = timestamp();

MERGE (ob:OBJECT {value:"<p>j'adore !</p>",
                format: "text/html"})
ON CREATE SET ob.created = timestamp()
WITH ob
MATCH (ty:TYPE {type: "TextualBody"})
CREATE (ty)<-[:isType]-(ob)<-[:Body]-(a:ANNOTATION {created:timestamp()})
WITH ob, a
MATCH (ln:LANGUAGE {language: "fr"})
CREATE (ob)-[:isLanguage]->(ln)
MERGE (ot:OBJECT {id:"http://example.org/photo1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a);
