## How many Code Repositories are in the Database

```
OPTIONAL MATCH (:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)-[:Target]-()
RETURN COUNT(DISTINCT ocr)
```

## How many Data Catalogs are in the Database

```
MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)
RETURN COUNT(DISTINCT odc)
```

## What Distinct Keywords have been Linked

No longer supported.

```
MATCH (:TYPE {type: "schema:DataCatalog"})-[:isType]-(ob:OBJECT)
UNWIND SPLIT(ob.keywords, ",") AS uwky
WITH toLower(TRIM(uwky)) AS keywords
RETURN DISTINCT keywords
```

## Find Linked Code and Data Repositories

This query returns all data repositories linked to multiple research databases.

```coffeescript
MATCH (:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)
WITH ocr
MATCH p=(:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc_a:OBJECT)-[:Target]-(:ANNOTATION)-[:Target]-(ocr)-[:Target]-(:ANNOTATION)-[:Target]-(odc_b:OBJECT)-[:isType]-(:TYPE {type:"schema:DataCatalog"})
WHERE odc_a <> odc_b
WITH DISTINCT ocr.name AS repo, ocr.description AS desc, COLLECT([odc_a.name, odc_b.name]) AS dbs
UNWIND dbs AS x
UNWIND x AS y
RETURN repo, desc, COLLECT(DISTINCT y) AS dbs, COUNT(DISTINCT y) AS n
ORDER BY n DESC
```

## Match a specific Database:

```coffeescript
MATCH p=(:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)-[]-(:ANNOTATION)-[]-()-[:isType]-(d:TYPE)
WHERE odc.name STARTS WITH "Neotoma"
RETURN p
```

## Return GitHub Users. Sort by number of linked repositories

```coffeescript
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(odc:OBJECT)
WITH SPLIT(odc.name, "/")[0] AS users
RETURN DISTINCT users, COUNT(users) AS n
ORDER BY n DESC
```

## How many different resources is a user associated with?

```coffeescript
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)-[]-(:ANNOTATION)-[]-(obc:OBJECT)-[:isType]-(:TYPE {type:"schema:DataCatalog"})
WITH SPLIT(ocr.name, "/")[0] AS owner, COUNT(DISTINCT obc.name) AS n, COLLECT(DISTINCT obc.name) AS resources
WHERE n > 3
RETURN owner, n, resources
ORDER BY n DESC, resources[0]
```

## Match a specific repository:

```coffeescript
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)-[]-(:ANNOTATION)-[]-()-[:isType]-(d:TYPE)
WHERE ocr.name = "jansergithub/awesome-public-datasets"
RETURN p
```

## Match all Databases with their code repositories by keyword.

```coffeescript
MATCH (kw:KEYWORD)
WHERE kw.keyword =~ '(earth)|(paleo)|(space)'
WITH kw
MATCH (db:dataCat)<-[:Body]-(:ANNOTATION)-[:hasKeyword]->(kw)
MATCH (db)<-[:Body]-(:ANNOTATION)-[:hasKeyword]->(allkws:KEYWORD)
MATCH (cr:codeRepo)<-[:Target]-(:ANNOTATION)-[:Target]->(db)
RETURN DISTINCT db.name AS name, COUNT(DISTINCT cr.url) AS repos, COLLECT(DISTINCT allkws.keyword) AS keywords
ORDER BY repos DESC
LIMIT 5
```
