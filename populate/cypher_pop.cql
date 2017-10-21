// A single person annotates a single record.

MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;

UNWIND 
MERGE (ann:annotation {created: timestamp()})
MERGE (bod:body {bodyValue: 'Core top date not accurate.'})
MERGE (creator:person {uid: '0000-0002-2700-4605', source:'http://orcid.org'})
MERGE (ann)<-[cre:creates]-(creator)
MERGE (ann)<-[annotates:annotates]-(bod)
MERGE (tar:target {uid: 'http://api.neotomadb.org/?siteid=12'})
MERGE (ann)-[tarr:targets]->(tar)
MERGE (tar)<-[in_db:contains]-(db:database {name:'Neotoma', uid:"10.17616/R3PD38", type:'doi'});

// A person links a record with an existing publication:
MERGE (ann:annotation {created: timestamp()})
MERGE (bod:body {bodyValue: 'Publication uses this dataset, but it\'s not indicated explicitly.'})-[ref:refers]->(ann:annotation {})-[tr:targets]->
MERGE (tar:target {uid: 'http://api.neotomadb.org/?siteid=12'})
MERGE (creator:person {uid: '0000-0003-4048-177X',source:'http://orcid.org'})
MERGE (ann)<-[cre:creates]-(creator)
MERGE (db:database {uid:"10.17616/R3PD38"})
MERGE (tar)<-[in_db:contains]-(db);

MERGE (bod:body {annotationText: 'Generated new age models.',url:''})-[ref:refers]->(ann:annotation {})-[tr:targets]->(tar:target {id: 'http://api.neotomadb.org/?siteid=12'})
WITH ann, tar
MERGE (ann)<-[cre:creates]-(creator:person {id: '0000-0002-2700-4605',source:'http://orcid.org'})
ON CREATE SET ann.created = timestamp()
ON MATCH SET ann.modified = timestamp()
MERGE (tar)<-[in_db:contains]-(db:database {doi:"10.17616/R3PD38"});

// The database generates a set of links:
MERGE (bod:body {bodyValue: 'Core top date not accurate.'})-[ref:refers]->(ann:annotation {})-[tr:targets]->(tar:target {id: 'http://api.neotomadb.org/?siteid=12'})
WITH ann
MERGE (ann)<-[cre:creates]-(creator:person {id: '0000-0002-2700-4605',source:'http://orcid.org'});
