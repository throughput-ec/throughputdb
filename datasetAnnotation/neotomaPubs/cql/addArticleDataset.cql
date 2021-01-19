MATCH (asy:AGENTTYPE {type: "SoftwareAgent"})
MATCH (aty:AGENTTYPE {type:"Person"})
MATCH (bty:TYPE {type:'TextualBody'})
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"})
ON CREATE SET ag.created = timestamp()
MERGE (ag)<-[:isAgentType]-(aty)
MERGE (ags:AGENT {name: "Linking datasets to publications in Neotoma",
                  homepage: "https://github.com/throughput-ec/throughputdb/Re3Databases"})
MERGE (ags)<-[:isAgentType]-(asy)
WITH ags, ag
  CREATE (a:ANNOTATION {created: timestamp()})
  MERGE (b:OBJECT {value: 'Annotation connecting publications to Neotoma datasets based on prior DeepDive work.'})
  MERGE  (b)<-[:Body]-(a)
  MERGE (a)<-[:Created]-(ag)
  MERGE (a)<-[:Generated]-(ags)
WITH a
  MATCH (db:dataCat) WHERE db.id = "r3d100011761"
  MATCH (ar:Article) WHERE ar.id = $doi
  MATCH (dsty:TYPE {type:'Dataset'})
  MERGE (ob:OBJECT {id: $dsid, level:'dataset'})
  MERGE (ob)-[:isType]->(dsty)
WITH a, db, ar, ob
  MERGE (db)-[:Contains]->(ob)
  MERGE (a)-[:Target]->(ob)
  MERGE (a)-[:Target]->(ar)
