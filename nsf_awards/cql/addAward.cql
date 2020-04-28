MERGE (dir:Directorate {name: $Organization.Directorate.LongName})
MERGE (div:Division {name: $Organization.Division.LongName, code: $Organization.Code})
WITH dir, div
MERGE (award:OBJECT {AwardID: $AwardID})
  ON CREATE SET award.name = $AwardTitle,
               award.amount = toInteger($AwardAmount),
                award.ARRAAmount = toInteger($ARRAAmount),
           award.AwardInstrument = $AwardInstrument,
         award.description = $AbstractNarration
MERGE (award)-[:fundedBy]->(div)-[dwn:divisionOf]->(dir)
  ON CREATE SET dwn.AwardID = [] + $AwardID
  ON  MATCH SET dwn.AwardID = CASE
    WHEN NOT $AwardID IN dwn.AwardID THEN dwn.AwardID + $AwardID
    ELSE dwn.AwardID
  END
With award
MATCH (g:TYPE {type:"schema:Grant"})
MERGE (award)-[:isType]->(g)
WITH award
UNWIND $ProgramElement AS pe
MERGE (pgrele:Program {Code:pe.Code, Text:pe.Text})
MERGE (award)-[fpg:Funded_by]-(pgrele)
  ON CREATE SET fpg.AwardID = [] + $AwardID
  ON  MATCH SET fpg.AwardID = CASE WHEN NOT $AwardID IN fpg.AwardID THEN fpg.AwardID + $AwardID
ELSE fpg.AwardID END
WITH award
UNWIND $ProgramReference AS pr
MERGE (pgrref:Program {Code:pr.Code, Text:pr.Text})
MERGE (award)-[rpg:Referenced_by]-(pgrref)
  ON CREATE SET rpg.AwardID = [] + $AwardID
  ON  MATCH SET rpg.AwardID = CASE WHEN NOT $AwardID IN rpg.AwardID THEN rpg.AwardID + $AwardID
ELSE rpg.AwardID END
