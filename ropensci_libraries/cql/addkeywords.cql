MERGE (asy:AGENTTYPE {type: "SoftwareAgent"})
MERGE (aty:AGENTTYPE {type:"Person"})
WITH aty, asy
  MATCH (o:OBJECT {id: $id})
  MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                    name: "Simon Goring"}) <-[:isAgentType]-(aty)
  ON CREATE SET ag.created = timestamp()
  MERGE (ags:AGENT {name: "Keyword addition",
                    homepage: "https://github.com/throughput-ec/throughputdb/ropensci_libraries"})<-[:isAgentType]-(asy)
  MERGE (o)<-[:Body]-(a:ANNOTATION)-[:Generated]->(ags)
    ON CREATE SET a.created = timestamp()
  MERGE (o)<-[:Body]-(a)-[:Created]->(ag)
  MERGE (mv:MOTIVATION {term:"tagging"})
  MERGE (mv)<-[:hasMotivation]-(a)
WITH a, o
  MERGE (dbt:OBJECT {value: "The repository is tagged with these terms."})-[:isType]->(:TYPE {type: "TextualBody"})
  MERGE (a)-[:Body]->(dbt)
WITH a, o
  UNWIND $keywords AS kword
    MERGE (knode:KEYWORD {keyword: rTrim(lTrim(tolower(kword)))})
      ON CREATE SET knode.created = timestamp()
    MERGE (a)-[hk:hasKeyword]->(knode)
      ON CREATE SET hk.created = timestamp()
