MATCH (asy:AGENTTYPE {type: "SoftwareAgent"})
MATCH (aty:AGENTTYPE {type:"Person"})
MATCH (bty:TYPE {type:'TextualBody'})
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"})
ON CREATE SET ag.created = timestamp()
MERGE (ag)<-[:isAgentType]-(aty)
MERGE (ags:AGENT {name: "Subject addition",
                  homepage: "https://github.com/throughput-ec/throughputdb/Re3Databases"})
MERGE (ags)<-[:isAgentType]-(asy)
WITH ags, ag
  CREATE (a:ANNOTATION {created: timestamp()})
  MERGE (b:OBJECT {value: 'Added subjects from re3data listings'})
  MERGE  (b)<-[:Body]-(a)
  MERGE (a)<-[:Created]-(ag)
  MERGE (a)<-[:Generated]-(ags)
WITH a
  MATCH (n:dataCat)
  WHERE n.id = $id
  SET n.contact = $contact
  MERGE (a)-[:Target]->(n)
WITH a
UNWIND $subjects AS subs
  MERGE (sc:SUBJECTSCHEMA {subjectScheme: subs.scheme})
  MERGE (su:SUBJECT {id: subs.subject.subjectid, subject: subs.subject.subject})
  MERGE (su)-[:hasScheme]->(sc)
  MERGE (a)-[:hasSubject]->(su)
