// All Agent relationships should reflect the grammar of
// the relationship type.
MATCH (ag:AGENT)<-[rel:Created]-(p:ANNOTATION)
CALL apoc.refactor.invert(rel)
yield input, output
RETURN input, output;

MATCH (ag:AGENT)<-[rel:Generated]-(p:ANNOTATION)
CALL apoc.refactor.invert(rel)
yield input, output
RETURN input, output;

// All relationships where the AgentType is the predicate need to be changed.
MATCH (ag:AGENT)<-[rel:isAgentType]-(p:AGENTTYPE)
CALL apoc.refactor.invert(rel)
yield input, output
RETURN input, output;

MATCH (ag:AGENT)<-[rel:isAgentType]-(p:AGENTTYPE)
WITH COLLECT(rel) AS RELS, ag
WHERE SIZE(RELS) > 1
UNWIND tail(RELS) as reltail
DELETE reltail