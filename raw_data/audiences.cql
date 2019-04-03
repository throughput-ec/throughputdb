UNWIND [
  "EducationalAudience",
  "PeopleAudience",
  "BusinessAudience"
] AS x
MERGE (:AUDIENCE {type: x})
