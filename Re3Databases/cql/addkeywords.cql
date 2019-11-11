MATCH  (o:OBJECT {id: "%s"})
CREATE (o)<-[:Body]-(a:ANNOTATION { created: timestamp() })
MERGE (tyt:TYPE {type: "TextualBody"})
MERGE (mv:MOTIVATION {term: "tagging"})
MERGE (aty:AGENTTYPE {type:"Person"})
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"}) <-[:isAgentType]-(aty)
ON CREATE SET ag.created = timestamp()
MERGE (ags:AGENT {name: "Keyword addition",
                  homepage: "https://github.com/throughput-ec/throughputdb/Re3Databases"}) <-[:isAgentType]- (aty)
MERGE (mv)<-[:hasMotivation]-(a)
WITH a, tyt, aty, o
  MERGE (a)-[:Body]->(obb:OBJECT {value: "The database is tagged with these terms."})-[:isType]->(tyt)
WITH a, o, SPLIT(o.keywords, ",") AS kw
  FOREACH (kword IN kw |
    MERGE  (a)-[:Target]->(k:KEYWORDS {keyword: kword})
    ON CREATE SET k.created = timestamp() )

RETURN kw, o.name
