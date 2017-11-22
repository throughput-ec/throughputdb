#!/bin/bash

export NEO4J_DATA=/media/simon/DATA3/throughputdb/data
export NEO4J_LOGS=/media/simon/DATA3/throughputdb/logs
export NEO4J_CONF=/media/simon/DATA3/throughputdb/conf

docker run --detach \
    --volume=$NEO4J_LOGS:/logs \
    --volume=$NEO4J_DATA:/data \
    --volume=$NEO4J_CONF:/conf \
    --name throughputdb \
    --publish=7474:7474 \
    --publish=7687:7687 \
    --ulimit=nofile=40000:40000 \
    neo4j:3.2