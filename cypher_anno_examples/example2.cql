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
