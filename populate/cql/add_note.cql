CREATE (ann:annotation {created: timestamp()})
WITH [{type:"TextualBody",value:"Age models rebuilt with new biostratigraphic markers."},{type:"ScholarlyArticle",value:"http://dx.doi.org/10.1016/j.quascirev.2011.04.017"}] as prop, ann
UNWIND prop AS bodyprop
MERGE (bod:body {type:bodyprop.type, value:bodyprop.value})
MERGE (ann)<-[annotates:annotates]-(bod)
WITH ann
MERGE (creator:person {uid: '0000-0002-2700-4605', source:'http://orcid.org'})
MERGE (ann)<-[cre:creates]-(creator)
MERGE (tar:target {uid: 'http://api.neotomadb.org/?siteid=12'})
MERGE (ann)-[tarr:targets]->(tar)
MERGE (tar)<-[in_db:contains]-(db:database {name:'Neotoma', uid:"10.17616/R3PD38", type:'doi'});
