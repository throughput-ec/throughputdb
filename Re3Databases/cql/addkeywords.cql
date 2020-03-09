MATCH  (o:OBJECT)
WHERE id(o) = %d
MERGE (aty:AGENTTYPE {type:"Person"})
WITH aty, o
  MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                    name: "Simon Goring"}) <-[:isAgentType]-(aty)
  ON CREATE SET ag.created = timestamp()
WITH aty, o
  MERGE (ags:AGENT {name: "Keyword addition",
                    homepage: "https://github.com/throughput-ec/throughputdb/Re3Databases"}) <-[:isAgentType]- (aty)
WITH o
  CREATE (o)<-[:Body]-(a:ANNOTATION { created: timestamp() })
WITH o, a
MERGE (mv:MOTIVATION {term: "tagging"})<-[:hasMotivation]-(a)
WITH o, a
  MERGE (a)-[:Body]->(:OBJECT {value: "The database is tagged with these terms."})-[:isType]->(:TYPE {type: "TextualBody"})
WITH o, a, SPLIT(o.keywords, ",") AS kw
  FOREACH (kword IN kw |
    MERGE (knode:KEYWORD {keyword: rTrim(lTrim(kword))})
      ON CREATE SET knode.created = timestamp()
      CREATE (a)-[:hasKeyword]->(knode) )
RETURN kw AS keywords, o.name AS name
