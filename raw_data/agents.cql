UNWIND ["Person", "Organization", "SoftwareAgent", "Undefined"] AS x
MERGE (:AGENTTYPE {type: x})
ON CREATE SET x.created = timestamp()
