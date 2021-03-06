WITH [
  {
    term: "assessing",
    type: "Instance",
    description: "The motivation for when the user intends to assess the target resource in some way, rather than simply make a comment about it. For example to write a review or assessment of a book, assess the quality of a dataset, or provide an assessment of a student's work."
  },
  {
    term: "bookmarking",
    type: "Instance",
    description: "The motivation for when the user intends to create a bookmark to the Target or part thereof. For example an Annotation that bookmarks the point in a text where the reader finished reading."
  },
  {
    term: "classifying",
    type: "Instance",
    description: "The motivation for when the user intends to classify the Target as something. For example to classify an image as a portrait."
  },
  {
    term: "commenting",
    type: "Instance",
    description: "The motivation for when the user intends to comment about the Target. For example to provide a commentary about a particular PDF document."
  },
  {
    term: "describing",
    type: "Instance",
    description: "The motivation for when the user intends to describe the Target, as opposed to (for example) a comment about it. For example describing the above PDF's contents, rather than commenting on their accuracy."
  },
  {
    term: "editing",
    type: "Instance",
    description: "The motivation for when the user intends to request a change or edit to the Target resource. For example an Annotation that requests a typo to be corrected."
  },
  {
    term: "highlighting",
    type: "Instance",
    description: "The motivation for when the user intends to highlight the Target resource or segment of it. For example to draw attention to the selected text that the annotator disagrees with."
  },
  {
    term: "identifying",
    type: "Instance",
    description: "The motivation for when the user intends to assign an identity to the Target. For example to associate the IRI that identifies a city with a mention of the city in a web page."
  },
  {
    term: "linking",
    type: "Instance",
    description: "The motivation for when the user intends to link to a resource related to the Target."
  },
  {
    term: "moderating",
    type: "Instance",
    description: "The motivation for when the user intends to assign some value or quality to the Target. For example annotating an Annotation to moderate it up in a trust network or threaded discussion."
  },
  {
    term: "questioning",
    type: "Instance",
    description: "The motivation for when the user intends to ask a question about the Target. For example to ask for assistance with a particular section of text, or question its veracity."
  },
  {
    term: "replying",
    type: "Instance",
    description: "The motivation for when the user intends to reply to a previous statement, either an Annotation or another resource. For example providing the assistance requested in the above."
  },
  {
    term: "tagging",
    type: "Instance",
    description: "The motivation for when the user intends to associate a tag with the Target."
  }
] AS long
UNWIND long AS x
MERGE (m:MOTIVATION {term: x.term, type: x.type, description: x.description })
ON CREATE SET m.created = timestamp();
