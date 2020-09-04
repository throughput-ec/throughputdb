CALL apoc.export.cypher.all("/tmp/dump.cypher", {
    format: "cypher-shell",
    useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
});

cat all.cypher | ./bin/cypher-shell -a <bolt-url> -u neo4j -p <password> --format verbose
