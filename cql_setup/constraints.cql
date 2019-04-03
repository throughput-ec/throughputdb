// A person must have an ORCID
CREATE CONSTRAINT ON (creator:creator) ASSERT creator.URL IS UNIQUE;

// A target must be marked by some unique identifier that is a string
CREATE CONSTRAINT ON (body:body) ASSERT body.id IS UNIQUE;

// A target must be marked by some unique identifier that is a string
CREATE CONSTRAINT ON (target:target) ASSERT target.body IS UNIQUE;

CREATE CONSTRAINT ON (rel:related) ASSERT rel.URL IS UNIQUE;

// Defining types:
// The asserted types are: Annotation, Body, Target, Embedded Textual Body, 
// Agent, Audience, Specific Resource, Fragment Selector, CSS Selector, 
// XPath Selector, Text Quote Selector, Text Position Selector, 
// Data Position Selector, SVG Selector, Time State, 
// Request Header State, CSS Stylesheet

// The annotation type must be unique, and must be within the controlled vocabulary
// CREATE CONSTRAINT ON ()-[istype:id]-() ASSERT istype.id IS UNIQUE;
// CREATE CONSTRAINT ON (year:year) ASSERT year.year IS UNIQUE;
// CREATE CONSTRAINT ON (month:month) ASSERT month.month IS UNIQUE;
// CREATE CONSTRAINT ON (day:day) ASSERT day.day IS UNIQUE;