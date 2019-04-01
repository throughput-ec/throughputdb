UNWIND ["Person", "Organization", "SoftwareAgent"] AS x
MERGE (:AGENT {type: x})
ON CREATE SET x.created = timestamp()
