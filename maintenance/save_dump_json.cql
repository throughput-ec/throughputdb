CALL apoc.export.cypher.all("/media/sdb/dump/dump.cypher", {
    format: "cypher-shell",
    useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
});

cat all.cypher | ./bin/cypher-shell -a <bolt-url> -u neo4j -p <password> --format verbose

CALL apoc.load.cypher('cypher-structure.json')
YIELD value
