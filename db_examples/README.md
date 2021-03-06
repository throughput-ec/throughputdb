# How many Code Repositories are in the Database

The actual concept is that an object can be one of many types. We have types for code repositories, data catalogs and others. To help speed up matching I've added labels to the `OBJECT` types so we can skip the first match. For example, data catalogs have the type `dataCat`, and code repositories have the type `codeRepo`.

## Traditional Match

Splitting the match into two lines (first matching `TYPE` and then matching the linked `OBJECT`) helps the query planner optimize more easily since there are few `TYPE` nodes.

```coffee
MATCH (crt:TYPE {type:"schema:CodeRepository"})
MATCH (crt)<-[:isType]-(ocr:OBJECT)
RETURN COUNT(DISTINCT ocr)
```

## Optimized Match

```coffee
MATCH (ocr:codeRepo)
RETURN COUNT(DISTINCT ocr)
```

## Optimized Match by Repository Description

```coffee
MATCH (ocr:codeRepo)
WHERE tolower(ocr.description) CONTAINS ('python')
RETURN COUNT(DISTINCT ocr)
```

# How many Data Catalogs are in the Database

Similar to the last match, we can optimize the following:

```coffee
MATCH (odc:dataCat)
RETURN COUNT(DISTINCT odc)
```

# Keywords

## Keywords Linked to Data Catalogs

We'll use the optimized labels here. We're splitting up the matches to help the optimizer, and we're using only keywords associated with the data catalogs.

### Distinct Keywords

A keyword is connected to an `OBJECT` node by an annotation, with the relationship `hasKeyword`. We can look at all keywords (limited here to the first 10). Here we're just looking at data catalogs, but we could switch `dataCat` for `OBJECT` which would also include keywords associated with journal articles and code repositories.

```coffee
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)<-[:Target]-(:ANNOTATION)-[:hasKeyword]->(kw)
RETURN DISTINCT kw
LIMIT 10
```

### Distinct Keywords with Counts

This list is ordered by the number of times a keyword is linked.

```coffee
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)<-[:Target]-(:ANNOTATION)-[:hasKeyword]->(kw)
RETURN DISTINCT kw, COUNT(odc) AS dbs
ORDER BY dbs DESC
LIMIT 10
```

### Keywords Collected by Database

You could replace `dataCat` with `codeRep` to get the keywords associated with code repositories, or you could use `OBJECT` for all objects with keywords.

```coffee
MATCH (odc:dataCat)
MATCH (kw:KEYWORD)
MATCH (odc)<-[:Target]-(:ANNOTATION)-[:hasKeyword]->(kw)
RETURN DISTINCT odc, COLLECT(kw) AS keywords
LIMIT 10
```

# Find Linked Code and Data Repositories

## One Code Repo per Row, Multiple Databases

This query returns all data repositories linked to each code repository. We create and unwind `dbs` because there are instances when (it appears) a database is connected to a code repository multiple times.

```coffee
MATCH (ocr:codeRepo)
MATCH (odb:dataCat)
MATCH (ocr)<-[:Target]-(:ANNOTATION)-[:Target]->(odb)
WITH DISTINCT ocr.name AS repo, ocr.description AS desc, COLLECT([odb.name, odb.description]) AS dbs
UNWIND dbs AS x
RETURN repo, desc, COLLECT(DISTINCT x) AS dbs, COUNT(DISTINCT x) AS n
ORDER BY n DESC
LIMIT 10
```

# Match Code Repos Connected to a Specific Database (graphs):

Here we're looking for code repositories connected to a specific database (identified using its name), and returning the graph as an object in the browser.

```coffee
MATCH (odb:dataCat)
WHERE odc.name STARTS WITH "Neotoma"
WITH odb
MATCH p=(odb)-[]-(:ANNOTATION)-[]-(:codeRepo)
RETURN p
LIMIT 10
```

# Return GitHub Users. Sort by number of linked repositories

```coffee
MATCH (ocr:codeRepo)
WITH SPLIT(ocr.name, "/")[0] AS users
RETURN DISTINCT users, COUNT(users) AS n
ORDER BY n DESC
LIMIT 10
```

# How many different resources is a user associated with?

```coffee
MATCH (ocr:codeRepo)
MATCH (odb:dataCat)
WITH SPLIT(ocr.name, "/")[0] AS owner, COUNT(DISTINCT odb.name) AS n, COLLECT(DISTINCT odb.name) AS resources
WHERE n > 3
RETURN owner, n, resources
ORDER BY n DESC, resources[0]
LIMIT 10
```

# Match a Specific Repository and Visualize All `OBJECT` Links

```coffee
MATCH p=(ocr:codeRepo)-[]-(:ANNOTATION)-[]-()-[:isType]-(:TYPE)
WHERE ocr.name = "jansergithub/awesome-public-datasets"
RETURN p
```
