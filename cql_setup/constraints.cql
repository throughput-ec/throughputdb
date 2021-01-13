// An object person must have a unique URL and/or identifier
CREATE CONSTRAINT ON (o:OBJECT) ASSERT o.id IS UNIQUE;

// A person must have some sort of unique identifier
CREATE CONSTRAINT ON (p:AGENT) ASSERT p.id IS UNIQUE;

// A keyword must be unique
CREATE CONSTRAINT ON (k:KEYWORDS) ASSERT k.keyword IS UNIQUE;

// A grant ID must be unique:
CREATE CONSTRAINT ON (o:OBJECT) ASSERT o.AwardID IS UNIQUE;

CREATE INDEX otherid FOR (o:OBJECT) ON (o.id);

CREATE INDEX objname FOR (o:OBJECT) ON (o.name);

CALL db.index.fulltext.createNodeIndex("namesAndDescriptions",["OBJECT"],["name", "description"])
