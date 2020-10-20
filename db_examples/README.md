# How many Code Repositories are in the Database

The actual concept is that an object can be one of many types. We have types for code repositories, data catalogs and others. To help speed up matching I've added labels to the `OBJECT` types so we can skip the first match. For example, data catalogs have the type `dataCat`, and code repositories have the type `codeRepo`.

## Traditional Match

Splitting the match into two lines (first matching `TYPE` and then matching the linked `OBJECT`) helps the query planner optimize more easily since there are few `TYPE` nodes.

```cypher
MATCH (crt:TYPE {type:"schema:CodeRepository"})
MATCH (crt)<-[:isType]-(ocr:OBJECT)
RETURN COUNT(DISTINCT ocr)
```

## Optimized Match

```cypher
MATCH (ocr:codeRep)
RETURN COUNT(DISTINCT ocr)
```

# How many Data Catalogs are in the Database

Similar to the last match, we can optimize the following:

```
MATCH (:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)
RETURN COUNT(DISTINCT odc)
```

Using:

```
MATCH (odc:dataCat)
RETURN COUNT(DISTINCT odc)
```

# Keywords

## Keywords Linked to Data Catalogs

We'll use the optimized labels here. We're splitting up the matches to help the optimizer, and we're using only keywords associated with the data catalogs.

### Distinct Keywords

```
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)-[:hasKeyword]->(kw)
RETURN DISTINCT kw
```

### Distinct Keywords with Counts

```
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)-[:hasKeyword]->(kw)
RETURN DISTINCT kw, COUNT(odc) AS dbs
ORDER BY dbs DESC
```

### Keywords Collected by Database

```
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)-[:hasKeyword]->(kw)
RETURN DISTINCT odc, COLLECT(kw) AS keywords
```

# Find Linked Code and Data Repositories

This query returns all data repositories linked to multiple research databases.

```coffee
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

# Match a specific Database:

```coffee
MATCH p=(:TYPE {type:"schema:DataCatalog"})-[:isType]-(odc:OBJECT)-[]-(:ANNOTATION)-[]-()-[:isType]-(d:TYPE)
WHERE odc.name STARTS WITH "Neotoma"
RETURN p
```

# Return GitHub Users. Sort by number of linked repositories

```coffee
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(odc:OBJECT)
WITH SPLIT(odc.name, "/")[0] AS users
RETURN DISTINCT users, COUNT(users) AS n
ORDER BY n DESC
```

# How many different resources is a user associated with?

```coffee
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)-[]-(:ANNOTATION)-[]-(obc:OBJECT)-[:isType]-(:TYPE {type:"schema:DataCatalog"})
WITH SPLIT(ocr.name, "/")[0] AS owner, COUNT(DISTINCT obc.name) AS n, COLLECT(DISTINCT obc.name) AS resources
WHERE n > 3
RETURN owner, n, resources
ORDER BY n DESC, resources[0]
```

# Match a specific repository:

```coffee
MATCH p=(:TYPE {type:"schema:CodeRepository"})-[:isType]-(ocr:OBJECT)-[]-(:ANNOTATION)-[]-()-[:isType]-(d:TYPE)
WHERE ocr.name = "jansergithub/awesome-public-datasets"
RETURN p
```
