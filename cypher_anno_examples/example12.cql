// Web Annotation Example 12:
// https://www.w3.org/TR/annotation-model/#agents
// {
//   "@context": "http://www.w3.org/ns/anno.jsonld",
//   "id": "http://example.org/anno12",
//   "type": "Annotation",
//   "creator": {
//     "id": "http://example.org/user1",
//     "type": "Person",
//     "name": "My Pseudonym",
//     "nickname": "pseudo",
//     "email_sha1": "58bad08927902ff9307b621c54716dcc5083e339"
//   },
//   "generator": {
//     "id": "http://example.org/client1",
//     "type": "Software",
//     "name": "Code v2.1",
//     "homepage": "http://example.org/client1/homepage1"
//   },
//   "body": "http://example.net/review1",
//   "target": "http://example.com/restaurant1"
// }

MATCH (n) DETACH DELETE n;

MERGE (ob:OBJECT { id:"http://example.net/review1"})
ON CREATE SET ob.created = timestamp()
MERGE (ag:AGENT { id:"http://example.org/user1",
                  name: "My Pseudonym",
                  nickname: "pseudo",
                  email_sha1: "58bad08927902ff9307b621c54716dcc5083e339"}) <-[:isAgentType]- (:AGENTTYPE {type:"Person"})
ON CREATE SET ag.created = timestamp()
MERGE (ags:AGENT { id:"http://example.org/client1",
                  name: "Code v2.1",
                  homepage: "http://example.org/client1/homepage1"}) <-[:isAgentType]- (:AGENTTYPE {type:"Software"})
ON CREATE SET ags.created = timestamp()
WITH ob, ags, ag
MERGE (ag)-[:Created {created: timestamp()}]->(a:ANNOTATION {created: timestamp()})-[:Body]->(ob)
MERGE (ags)-[:Generated {generated: timestamp()}]->(a)
WITH a
MERGE (ot:OBJECT {id: "http://example.com/restaurant1"})
ON CREATE SET ot.created = timestamp()
CREATE (ot)<-[:Target]-(a)
