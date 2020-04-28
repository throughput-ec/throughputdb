MATCH (award:OBJECT {AwardID: $AwardID})

UNWIND $Institution AS inst
  MERGE ( state:State { Name: toUpper(inst.StateName) })
  ON CREATE SET  state.Code = toUpper(inst.StateCode)
  MERGE (country:Country { Name: toUpper(inst.CountryName) } )
  MERGE (institution:Institution { name: inst.Name } )
  ON CREATE SET institution.phonenumber = inst.PhoneNumber,
                   institution.cityname = toUpper(inst.CityName),
              institution.streetaddress = toUpper(inst.StreetAddress),
                    institution.zipcode = inst.ZipCode

  MERGE (institution)-[is:In_State]->(state)
    ON CREATE SET is.AwardID = [] + $AwardID
    ON  MATCH SET is.AwardID = is.AwardID + $AwardID

  // This shouldnt be necessary in practice, but there may be a reason for keeping it.
  MERGE (state)-[ic:In_Country]->(country)
    ON CREATE SET ic.AwardID = [] + $AwardID
    ON  MATCH SET ic.AwardID = ic.AwardID + $AwardID

  MERGE (award)-[ai:Administered_by]->(institution)
