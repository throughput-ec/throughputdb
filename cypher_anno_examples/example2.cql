// Web Annotation Example 2:
// https://www.w3.org/TR/annotation-model/#bodies-and-targets
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno2",
//   "type": "Annotation",
//   "body": {
//     "id": "http://example.org/analysis1.mp3",
//     "format": "audio/mpeg",
//     "language": "fr"
//   },
//   "target": {
//     "id": "http://example.gov/patent1.pdf",
//     "format": "application/pdf",
//     "language": ["en", "ar"],
//     "textDirection": "ltr",
//     "processingLanguage": "en"
//   }
// }

// NOTE:  All formats should be in a FORMAT node.
//        All languages should be in a LANGUAGE node.

MERGE (ob:OBJECT {id: "http://example.org/analysis1.mp3",
                  format: "audio/mpeg",
                  language: "fr"})
ON CREATE SET ob.created = timestamp()
CREATE (ob)<-[b:Body]-(a:ANNOTATION { created: timestamp() })
MERGE (ot:OBJECT {    id: "http://example.gov/patent1.pdf",
                      format: "application/pdf",
                      language: ["en", "ar"],
                      textDirection: "ltr",
                      processingLanguage: "en"})
ON CREATE SET ot.created = timestamp()
CREATE (a)-[t:Target]->(ot)
