UNWIND ["Person", "Organization", "SoftwareAgent", "Undefined"] AS x
MERGE (aty:AGENTTYPE {type: x})
ON CREATE SET aty.created = timestamp()
