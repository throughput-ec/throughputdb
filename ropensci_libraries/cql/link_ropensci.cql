MERGE (ropen:OBJECT {  id: $parentid,
                     name: $parentname,
                      url: $parenturl,
              description: $parentdescription})
  ON CREATE SET ropen.created = timestamp()
MERGE (ty:TYPE {type: "schema:CodeRepository"})
MERGE (tyt:TYPE {type: "TextualBody"})
MERGE (mv:MOTIVATION {term: "linking"})
MERGE (aty:AGENTTYPE {type:"Person"})
MERGE (child:OBJECT {  id: $id,
                     name: $name,
                      url: $url,
              description: $description})-[:isType]->(ty)
  ON CREATE SET child.created = timestamp()
WITH ty, tyt, ropen, child, mv, aty
  MERGE (ty)<-[:isType]-(ropen)
  MERGE (ty)<-[:isType]-(child)
  MERGE (ropen)<-[:Target]-(a:ANNOTATION)-[:Target]->(child)
    ON CREATE SET a.created = timestamp()
  MERGE (mv)<-[:hasMotivation]-(a)
  MERGE (a)-[:Body]->(obb:OBJECT)-[:isType]->(tyt)
    ON CREATE SET obb.value = $annotation
  MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                    name: "Simon Goring"}) <-[:isAgentType]-(aty)
    ON CREATE SET ag.created = timestamp()
  MERGE (ags:AGENT {name: "ROpensci Code Addition",
                    homepage: "https://github.com/throughput-ec/throughputdb/ropensci_libraries"}) <-[:isAgentType]- (aty)
WITH a, ag, ags
  MERGE (ag)-[cr:Created]->(a)
    ON CREATE SET cr.created = timestamp()
  MERGE (ags)-[gr:Generated]->(a)
    ON CREATE SET gr.generated = timestamp()
