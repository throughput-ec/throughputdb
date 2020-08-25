MATCH (db:OBJECT) WHERE db.id = $dbid
MERGE (anntype:TYPE {type: "TextualBody"})
MERGE (asy:AGENTTYPE {type: "SoftwareAgent"})
MERGE (aty:AGENTTYPE {type:"Person"})
WITH aty, asy, db, anntype
  MERGE (ag:AGENT { id:$orcid,
                    name: $agent}) <-[:isAgentType]-(aty)
  ON CREATE SET ag.created = timestamp()
  MERGE (ags:AGENT {name: "Dataset Annotation",
                    homepage: "https://github.com/throughput-ec/throughputdb"})<-[:isAgentType]-(asy)
  MERGE (db)<-[:Body]-(a:ANNOTATION)-[:Generated]->(ags)
    ON CREATE SET a.created = timestamp()
  MERGE (db)<-[:Body]-(a)-[:Created]->(ag)
  MERGE (mv:MOTIVATION) WHERE term="describing"
  MERGE (mv)<-[:hasMotivation]-(a)
WITH a, db
  MERGE (dbt:OBJECT {value: $annotation})-[:isType]->(:TYPE {type: "TextualBody"})
  MERGE (a)-[:Body]->(dbt)
WITH a
  CREATE (ann:OBJECT {id: {level: $level, id:$linkid}, description: $annotation})
  MERGE (ann)<-[:Body]-(a:ANNOTATION)
