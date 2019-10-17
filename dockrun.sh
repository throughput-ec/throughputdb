#!/bin/bash

docker run \
    --name testneo4j \
    -p7474:7474 -p7687:7687 \
    -d \
    -v $HOME/neo4j/data:/data \
    -v $HOME/neo4j/logs:/logs \
    -v $HOME/neo4j/import:/var/lib/neo4j/import \
    -v $HOME/neo4j/plugins:/plugins \
    --ulimit=nofile=40000:40000 \
    --env NEO4J_AUTH=neo4j/test \
    neo4j:latest 2> /dev/null || \
    docker start testneo4j

pip3 install py2neo requests PyGithub
