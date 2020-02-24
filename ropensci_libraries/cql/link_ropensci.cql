MERGE (ob:OBJECT {id: "%s",
                  name: "%s",
                  url: "%s",
                  description: "%s"})
ON CREATE SET ob.created = timestamp()
MERGE (ty:TYPE {type: "schema:CodeRepository"})
MERGE (tyt:TYPE {type: "TextualBody"})
MERGE (mv:MOTIVATION {term: "linking"})
MERGE (aty:AGENTTYPE {type:"Person"})
MERGE (ors:OBJECT {name: "%s",
                  keywords: "%s",
                  url: "%s",
                  description: "%s"})-[:isType]->(ty)
ON CREATE SET ors.created = timestamp()
WITH ty, tyt, ob, ors, mv, aty
MERGE (ty)<-[:isType]-(ob)
CREATE (ob)<-[:Target]-(a:ANNOTATION { created: timestamp() })
MERGE (mv)<-[:hasMotivation]-(a)
MERGE (obb:OBJECT {value: "%s"})-[:isType]->(tyt)
MERGE (a)-[:Body]->(obb)
MERGE (ty)<-[:isType]-(ors)
MERGE (ors)<-[:Target]-(a)
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"}) <-[:isAgentType]-(aty)
ON CREATE SET ag.created = timestamp()
MERGE (ags:AGENT {name: "Database addition",
                  homepage: "https://github.com/throughput-ec/throughputdb"}) <-[:isAgentType]- (aty)
WITH a, ag, ags
MERGE (ag)-[:Created {created: timestamp()}]->(a)
MERGE (ags)-[:Generated {generated: timestamp()}]->(a)
