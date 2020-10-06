CALL apoc.export.cypher.all("/tmp/dump.cypher", {
    format: "cypher-shell",
    useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
});

cat all.cypher | ./bin/cypher-shell -a <bolt-url> -u neo4j -p <password> --format verbose

// File ownership issues:
WITH "MATCH (o)-[]-(o1)
      RETURN (o)-[]-(o1)
      LIMIT 10000" AS query
CALL apoc.export.cypher.query(query, "/tmp/cypher-structure.json")
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;


CALL apoc.load.json('cypher-structure.json')
YIELD value
