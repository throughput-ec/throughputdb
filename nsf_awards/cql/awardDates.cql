MATCH (award:OBJECT {AwardID: $AwardID})
MERGE ( year:Year   {Year: toInteger(SPLIT($AwardEffectiveDate, '/')[2]) } )
MERGE (month:Month {Month: toInteger(SPLIT($AwardEffectiveDate, '/')[0]) } )

MERGE (award)-[yst:Year_Started]-(year)
  ON CREATE SET yst.AwardID = [] + $AwardID
  ON  MATCH SET yst.AwardID = CASE WHEN NOT $AwardID IN yst.AwardID THEN yst.AwardID + $AwardID
ELSE yst.AwardID END

MERGE (year)-[mst:Month_Started]-(month)
  ON CREATE SET mst.AwardID = [] + $AwardID
  ON  MATCH SET  mst.AwardID = CASE WHEN NOT $AwardID IN mst.AwardID THEN mst.AwardID + $AwardID
ELSE mst.AwardID END

// Dates for awards - End date:
MERGE ( year_end:Year   {Year: toInteger(SPLIT($AwardExpirationDate, '/')[2]) } )
MERGE (month_end:Month {Month: toInteger(SPLIT($AwardExpirationDate, '/')[0]) } )

MERGE (award)-[yen:Year_Expired]-(year_end)
  ON CREATE SET yen.AwardID = [] + $AwardID
  ON  MATCH SET yen.AwardID = CASE WHEN NOT $AwardID IN yen.AwardID THEN yen.AwardID + $AwardID
ELSE yen.AwardID END

MERGE (year_end)-[men:Month_Expired]-(month_end)
  ON CREATE SET men.AwardID = [] + $AwardID
  ON  MATCH SET men.AwardID = CASE WHEN NOT $AwardID IN men.AwardID THEN men.AwardID + $AwardID
ELSE men.AwardID END

// Dates for awards - Amendment Letter min date:
MERGE  (year_amdS:Year   {Year: toInteger(SPLIT($MinAmdLetterDate, '/')[2]) } )
MERGE (month_amdS:Month {Month: toInteger(SPLIT($MinAmdLetterDate, '/')[0]) } )

MERGE (award)-[yam:Year_Amended_Min]-(year_amdS)
  ON CREATE SET yam.AwardID = [] + $AwardID
  ON  MATCH SET yam.AwardID = CASE WHEN NOT $AwardID IN yam.AwardID THEN yam.AwardID + $AwardID
ELSE yam.AwardID END

MERGE (year_amdS)-[mam:Month_Amended_Min]-(month_amdS)
  ON CREATE SET mam.AwardID = [] + $AwardID
  ON  MATCH SET mam.AwardID = CASE WHEN NOT $AwardID IN mam.AwardID THEN mam.AwardID + $AwardID
ELSE mam.AwardID END

// Dates for awards - Amendment letter max date:
MERGE (year_amdE:Year    {Year: toInteger(SPLIT($MaxAmdLetterDate, '/')[2])})
MERGE (month_amdE:Month {Month: toInteger(SPLIT($MaxAmdLetterDate, '/')[0])})

MERGE (award)-[ymx:Year_Amended_Max]-(year_amdE)
  ON CREATE SET ymx.AwardID = [] + $AwardID
  ON  MATCH SET ymx.AwardID = CASE WHEN NOT $AwardID IN ymx.AwardID THEN ymx.AwardID + $AwardID
  ELSE ymx.AwardID END

MERGE (year_amdE)-[mmx:Month_Amended_Max]-(month_amdE)
  ON CREATE SET mmx.AwardID = [] + $AwardID
  ON MATCH SET mmx.AwardID = CASE WHEN NOT $AwardID IN mmx.AwardID THEN mmx.AwardID + $AwardID
  ELSE mmx.AwardID END
