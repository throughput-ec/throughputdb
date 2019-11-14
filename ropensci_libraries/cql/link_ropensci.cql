MERGE (ob:OBJECT {id: "%s",
                  name: "%s",
                  url: "%s",
                  description: "%s"})
ON CREATE SET ob.created = timestamp()
MERGE (ty:TYPE {type: "schema:CodeRepository"})
MERGE (tyt:TYPE {type: "TextualBody"})
MERGE (mv:MOTIVATION {term: "linking"})
MERGE (aty:AGENTTYPE {type:"Person"})
WITH ty, tyt, ob, mv, aty
MERGE (ty)<-[:isType]-(ob)
CREATE (ob)<-[:Target]-(a:ANNOTATION { created: timestamp() })
MERGE (mv)<-[:hasMotivation]-(a)
MERGE (a)-[:Body]->(obb:OBJECT {value: "rOpenSci R package."})-[:isType]->(tyt)
MERGE (ot:OBJECT {id: "",
                  name: "rOpenSci organization.",
                  url: "https://www.ropensci.org/"})
ON CREATE SET ot.created = timestamp()
MERGE (ty)<-[:isType]-(ot)
MERGE (ot)<-[:Target]-(a)
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"}) <-[:isAgentType]-(aty)
ON CREATE SET ag.created = timestamp()
MERGE (ags:AGENT {name: "Database addition",
                  homepage: "https://github.com/throughput-ec/throughputdb"}) <-[:isAgentType]- (aty)
WITH a, ag, ags
MERGE (ag)-[:Created {created: timestamp()}]->(a)
MERGE (ags)-[:Generated {generated: timestamp()}]->(a)
