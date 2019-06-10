# Adding Databases to the Graph

A number of scientific databases exist and many are catalogued using Re3Data.

The model looks like this:

body:
  id: DOI
  Type: schema:DataCatalog
  name: Neotoma Paleoecology Database
  . . .
Target:
  id: DOI
  type: schema:DataCatalog
  name: re3data (www.re3data.org)

Each of these is an "object" in the sense of Throughput.  The type is linked through the `Type` node.

```cql
MERGE (ob:OBJECT {id: "10.17616/R3PD38",
                  name: "Neotoma Paleoecology Database",
                  url: "http://neotomadb.org",
                  keywords: ["paleoenvironments", "fossil mammals (FAUNMAP)",
                             "Pliocene", "neotoma", "biology", "Quaternary",
                             "FAUNMAP", "paleontology", "fossil data",
                             "North American Pollen Database (NAPD)"],
                  description: "Neotoma is a multiproxy paleoecological database that covers the Pliocene-Quaternary, including modern microfossil samples. The database is an international collaborative effort among individuals from 19 institutions, representing multiple constituent databases. There are over 20 data-types within the Neotoma Paleoecological Database, including pollen microfossils, plant macrofossils, vertebrate fauna, diatoms, charcoal, biomarkers, ostracodes, physical sedimentology and water chemistry. Neotoma provides an underlying cyberinfrastructure that enables the development of common software tools for data ingest, discovery, display, analysis, and distribution, while giving domain scientists control over critical taxonomic and other data quality issues."})
ON CREATE SET ob.created = timestamp()
CREATE (:TYPE {type: "schema:DataCatalog"})<-[:isType]-(ob)<-[:Target]-(a:ANNOTATION { created: timestamp() })
MERGE (a)-[:Body]->(obb:OBJECT {value: "Neotoma is contained within re3Data."})-[:isType]->(:TYPE {type:"TextualBody"})
MERGE (ot:OBJECT {id: "10.17616/R3D",
                  name: "Registry of Research Data Repositories",
                  url: "https://www.re3data.org/"})
ON CREATE SET ot.created = timestamp()
CREATE (:TYPE {type: "schema:DataCatalog"})<-[:isType]-(ot)<-[:Target]-(a)
CREATE (:MOTIVATION {term: "linking"})<-[:hasMotivation]-(a)
MERGE (ag:AGENT { id:"0000-0002-2700-4605",
                  name: "Simon Goring"}) <-[:isAgentType]- (:AGENTTYPE {type:"Person"})
ON CREATE SET ag.created = timestamp()
MERGE (ags:AGENT {name: "Database addition",
                  homepage: "https://github.com/throughput-ec/throughputdb"}) <-[:isAgentType]- (:AGENTTYPE {type:"Software"})
WITH a, ag, ags
MERGE (ag)-[:Created {created: timestamp()}]->(a)
MERGE (ags)-[:Generated {generated: timestamp()}]->(a)
```
