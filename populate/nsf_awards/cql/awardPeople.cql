MATCH (award:OBJECT {AwardID: $AwardID})-[:Administered_by]->(inst:Institution)
WITH award, inst
UNWIND $Investigator AS inv
MATCH (agty:AGENTTYPE {type:"Person"})
WITH award, agty, inst
MERGE (agt:AGENT {name: inv.LastName + ", " + inv.FirstName, email: inv.EmailAddress})
MERGE (agty)<-[:isAgentType]-(agt)
MERGE (agt)-[:hasGrant {role: inv.RoleCode}]->(award)
CREATE (agt)-[:affiliatedWith {award: award.AwardID, start: inv.StartDate, end: inv.EndDate}]->(inst)
