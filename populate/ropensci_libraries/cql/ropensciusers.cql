MATCH p=(:TYPE {type:'schema:CodeRepository'})-[:isType]-(n:OBJECT)-[]-(:ANNOTATION)-[]-(o:OBJECT)-[:isType]-(:TYPE {type:'schema:CodeRepository'})
WHERE     o.name CONTAINS("http") AND
      o.name CONTAINS("ropensci") AND
                           n <> o AND
      NOT n.name CONTAINS('ropensci')
RETURN           n.name AS repository,
                  n.url AS url,
        COLLECT(o.name) AS ropensciPkg,
               COUNT(o) AS ropenscilinks
ORDER BY ropenscilinks DESC
LIMIT 100000
