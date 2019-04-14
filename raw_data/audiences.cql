UNWIND [
  "EducationalAudience",
  "PeopleAudience",
  "BusinessAudience"
] AS x
MERGE (au:AUDIENCE {type: x})
ON CREATE SET au.created = timestamp();
