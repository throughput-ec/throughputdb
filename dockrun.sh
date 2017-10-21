#!/bin/bash

docker run \
    --detach \
    --volume=.:/conf \
    --name throughputdb \
    --publish=7474:7474 \
    --publish=7687:7687 \
    --ulimit=nofile=40000:40000 \
    neo4j:3.2
