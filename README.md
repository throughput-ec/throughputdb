# neo4j Annotation Engine

This engine is designed to run in a docker container for deployment portability & to facilitate reproducibility among collaborators.  The intention of this engine is to provide a platform for credentialed crowd-sourcing of scientific records and publications without requiring underlying data resources to manage additional unstructured data.  Annotations should follow the [WC3 Web Annotation](https://www.w3.org/TR/annotation-model/) protocols and follow a model that supports API first development.  As such, this database is in fact composed of two distinct elements, a database, built using neo4j, and an API built using node/express.

This repository contains the raw code for the neo4j Docker container, test data for populating the database, database scripts for the database schema and constraints, and helper cypher scripts.

## Contributions

*We welcome contributions from any individual, whether code, documentation, or issue tracking.  All participants are expected to follow the [code of conduct](https://github.com/SimonGoring/Throughput/blob/master/code_of_conduct.md) for this project.*

[Simon Goring](http://goring.org) - University of Wisconsin Madison

## Using this Repository

This repository contains a bash script called `dockrun.sh` that can be executed to initialize the container.  Currently most of the settings for the neo4j image are default, with the exception of the locations for the data and log files, along with setting the upper page file limit for the database.  To initialize the database and docker instance simply run:

```coffeescript
> bash dockrun.sh
```

