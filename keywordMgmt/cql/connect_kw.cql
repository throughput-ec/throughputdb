MATCH (olk:KEYWORD {keyword: $kwIn})
MATCH (ag:AGENT { id:"0000-0002-2700-4605", name: "Simon Goring"})
MATCH (asy:AGENTTYPE {type: "SoftwareAgent"})
MATCH (aty:AGENTTYPE {type:"Person"})
WITH olk, ag, asy, aty
  MERGE (ags:AGENT {name: "Keyword synonymy",
                    homepage: "https://github.com/throughput-ec/throughputdb/keywordMgmt"})
  MERGE (ag)<-[:isAgentType]-(aty)
  MERGE (ags)<-[:isAgentType]-(asy)
  CREATE (a:ANNOTATION)
  CREATE (ag)<-[:Created]-(a)
  CREATE (ag)<-[:Generated]-(a)
WITH olk, a
UNWIND $term AS term
  MERGE (nlk:KEYWORD {keyword: term})
    ON CREATE SET nlk.created = timestamp()
  CREATE (nlk)<-[:isSynonym]-(a)-[:isSynonym]->(olk)
