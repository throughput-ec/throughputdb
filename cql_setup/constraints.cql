// An object person must have a unique URL and/or identifier
// Requires Enterprise Edition:
// CREATE CONSTRAINT ON (o:OBJECT) ASSERT (o.id, o.url) IS NODE KEY;
CREATE CONSTRAINT ON (o:OBJECT) ASSERT o.id IS UNIQUE;

// A person must have some sort of unque identifier
CREATE CONSTRAINT ON (p:AGENT) ASSERT p.id IS UNIQUE;

// A keyword must be unique
CREATE CONSTRAINT ON (k:KEYWORDS) ASSERT k.keyword IS UNIQUE;
