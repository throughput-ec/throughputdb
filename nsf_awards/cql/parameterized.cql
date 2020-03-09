MERGE (award:OBJECT {AwardID: '|AwardID|'})
  ON CREATE SET award.name = toUpper('|AwardTitle|'),
               award.amount = toInteger('|AwardAmount|'),
                award.ARRAAmount = toInteger('|ARRAAmount|'),
           award.AwardInstrument = '|AwardInstrument|',
         award.description = '|AbstractNarration|'

MERGE (award)-[:isType]-(:TYPE {type:"schema:Grant"})

MERGE ( state:State { Name: toUpper('|InstitutionStateName|') })
ON CREATE SET  state.Code = toUpper('|InstitutionStateCode|')

MERGE (country:Country { Name: toUpper('|InstitutionCountryName|') } )

MERGE (institution:Institution { Name: toUpper('|InstitutionName|') } )
ON CREATE SET institution.PhoneNumber = '|InstitutionPhoneNumber|',
                 institution.CityName = toUpper('|InstitutionCityName|'),
            institution.StreetAddress = toUpper('|InstitutionStreetAddress|'),
                  institution.ZipCode = '|InstitutionZipCode|'

MERGE (institution)-[is:In_State]->(state)
  ON CREATE SET is.AwardID = [] + '|AwardID|'
  ON  MATCH SET is.AwardID = is.AwardID + '|AwardID|'

// This shouldnt be necessary in practice, but there may be a reason for keeping it.
MERGE (state)-[ic:In_Country]->(country)
  ON CREATE SET ic.AwardID = [] + '|AwardID|'
  ON  MATCH SET ic.AwardID = ic.AwardID + '|AwardID|'

MERGE (award)-[ai:Administered_by]->(institution)

// Dates for awards -
// Here we do two things, we first make the matches, and then we add the
// award number to the paths relationship element.
//
// Start date:
// As with others, this has to be done year, then month because otherwise the unique
// constraint of the award number screws things up.

MERGE ( year:Year   {Year: toInteger(SPLIT('|AwardEffectiveDate|', '/')[2]) } )
MERGE (month:Month {Month: toInteger(SPLIT('|AwardEffectiveDate|', '/')[0]) } )

MERGE (award)-[yst:Year_Started]-(year)
  ON CREATE SET yst.AwardID = [] + '|AwardID|'
  ON  MATCH SET yst.AwardID = CASE WHEN NOT '|AwardID|' IN yst.AwardID THEN yst.AwardID + '|AwardID|'
ELSE yst.AwardID END

MERGE (year)-[mst:Month_Started]-(month)
  ON CREATE SET mst.AwardID = [] + '|AwardID|'
  ON  MATCH SET  mst.AwardID = CASE WHEN NOT '|AwardID|' IN mst.AwardID THEN mst.AwardID + '|AwardID|'
ELSE mst.AwardID END

// Dates for awards - End date:
MERGE ( year_end:Year   {Year: toInteger(SPLIT('|AwardExpirationDate|', '/')[2]) } )
MERGE (month_end:Month {Month: toInteger(SPLIT('|AwardExpirationDate|', '/')[0]) } )

MERGE (award)-[yen:Year_Expired]-(year_end)
  ON CREATE SET yen.AwardID = [] + '|AwardID|'
  ON  MATCH SET yen.AwardID = CASE WHEN NOT '|AwardID|' IN yen.AwardID THEN yen.AwardID + '|AwardID|'
ELSE yen.AwardID END

MERGE (year_end)-[men:Month_Expired]-(month_end)
  ON CREATE SET men.AwardID = [] + '|AwardID|'
  ON  MATCH SET men.AwardID = CASE WHEN NOT '|AwardID|' IN men.AwardID THEN men.AwardID + '|AwardID|'
ELSE men.AwardID END

// Dates for awards - Amendment Letter min date:
MERGE  (year_amdS:Year   {Year: toInteger(SPLIT('|MinAmdLetterDate|', '/')[2]) } )
MERGE (month_amdS:Month {Month: toInteger(SPLIT('|MinAmdLetterDate|', '/')[0]) } )

MERGE (award)-[yam:Year_Amended_Min]-(year_amdS)
  ON CREATE SET yam.AwardID = [] + '|AwardID|'
  ON  MATCH SET yam.AwardID = CASE WHEN NOT '|AwardID|' IN yam.AwardID THEN yam.AwardID + '|AwardID|'
ELSE yam.AwardID END

MERGE (year_amdS)-[mam:Month_Amended_Min]-(month_amdS)
  ON CREATE SET mam.AwardID = [] + '|AwardID|'
  ON  MATCH SET mam.AwardID = CASE WHEN NOT '|AwardID|' IN mam.AwardID THEN mam.AwardID + '|AwardID|'
ELSE mam.AwardID END

// Dates for awards - Amendment letter max date:
MERGE (year_amdE:Year    {Year: toInteger(SPLIT('|MaxAmdLetterDate|', '/')[2])})
MERGE (month_amdE:Month {Month: toInteger(SPLIT('|MaxAmdLetterDate|', '/')[0])})

MERGE (award)-[ymx:Year_Amended_Max]-(year_amdE)
  ON CREATE SET ymx.AwardID = [] + '|AwardID|'
  ON  MATCH SET ymx.AwardID = CASE WHEN NOT '|AwardID|' IN ymx.AwardID THEN ymx.AwardID + '|AwardID|'
  ELSE ymx.AwardID END

MERGE (year_amdE)-[mmx:Month_Amended_Max]-(month_amdE)
  ON CREATE SET mmx.AwardID = [] + '|AwardID|'
  ON MATCH SET mmx.AwardID = CASE WHEN NOT '|AwardID|' IN mmx.AwardID THEN mmx.AwardID + '|AwardID|'
  ELSE mmx.AwardID END

// Add the directorates and programs:
MERGE (direct:Directorate {Code: '|OrganizationCode|'})
  ON CREATE SET direct.Directorate = '|OrganizationDirectorate|'

MERGE (division:Division {Division: '|OrganizationDivision|'})

MERGE (direct)-[dwn:Within]-(division)
  ON CREATE SET dwn.AwardID = [] + '|AwardID|'
  ON  MATCH SET dwn.AwardID = CASE WHEN NOT '|AwardID|' IN dwn.AwardID THEN dwn.AwardID + '|AwardID|'
ELSE dwn.AwardID END

MERGE (award)-[fby:Funded_by]-(direct)
  ON CREATE SET fby.AwardID = [] + '|AwardID|'
  ON  MATCH SET fby.AwardID = CASE WHEN NOT '|AwardID|' IN fby.AwardID THEN fby.AwardID + '|AwardID|'
ELSE fby.AwardID END

MERGE (pgrele:Program {Code:'|ProgramElementCode|',   Text:'|ProgramElementText|'})
MERGE (pgrref:Program {Code:'|ProgramReferenceCode|', Text:'|ProgramReferenceText|'})

MERGE (award)-[fpg:Funded_by]-(pgrele)
  ON CREATE SET fpg.AwardID = [] + '|AwardID|'
  ON  MATCH SET fpg.AwardID = CASE WHEN NOT '|AwardID|' IN fpg.AwardID THEN fpg.AwardID + '|AwardID|'
ELSE fpg.AwardID END

MERGE (award)-[rpg:Referenced_by]-(pgrref)
  ON CREATE SET rpg.AwardID = [] + '|AwardID|'
  ON  MATCH SET rpg.AwardID = CASE WHEN NOT '|AwardID|' IN rpg.AwardID THEN rpg.AwardID + '|AwardID|'
ELSE rpg.AwardID END

MERGE (pgrref)-[pgmof:Program_of]-(division)
  ON CREATE SET pgmof.AwardID = [] + '|AwardID|'
  ON  MATCH SET pgmof.AwardID = CASE WHEN NOT '|AwardID|' IN pgmof.AwardID THEN pgmof.AwardID + '|AwardID|'
ELSE pgmof.AwardID END

MERGE (pgrele)-[pgmofb:Program_of]-(division)
  ON CREATE SET pgmofb.AwardID = [] + '|AwardID|'
  ON  MATCH SET pgmofb.AwardID = CASE WHEN NOT '|AwardID|' IN pgmofb.AwardID THEN pgmofb.AwardID + '|AwardID|'
    ELSE pgmofb.AwardID END
