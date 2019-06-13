# Annotation Examples

The W3C standards for annotations include a number of examples that indicate how annotations should be serialized using JSON-LD.  This directory translates the examples to Cypher queries (CQL files) so that the queries can then form the basis of an API that will access, retrieve and post data to and from the Annotation Engine.

## Examples:

These examples are drawn from the [Annotation Standards]() and rendered into CQL.  In some cases specific vocabularies are required.  For these vocabularies we have constructed sample data elements in the [`raw_data`](../raw_data) folder.  Those `raw_data` CQL queries are run on creation of the database, such that elements including `agents`, `motivation` and others, already exist within the database.

  * Example 1: [Basic Annotation Model](https://www.w3.org/TR/annotation-model/#annotations) ([cql](example1.cql))
  * Example 2: [External Web Resources](https://www.w3.org/TR/annotation-model/#external-web-resources)  ([cql](example2.cql))
  * Example 3: [Typing of Body and Target](https://www.w3.org/TR/annotation-model/#classes)  ([cql](example3.cql))
  * Example 4: [IRIs with Fragment Components](https://www.w3.org/TR/annotation-model/#segments-of-external-resources)  ([cql](example4.cql))
  * Example 5: [Textual Body](https://www.w3.org/TR/annotation-model/#embedded-textual-body) ([cql](example5.cql))
  * Example 6: [String Body](https://www.w3.org/TR/annotation-model/#string-body) ([cql](example6.cql))
  * Example 7: [Equivalent Textual Body](https://www.w3.org/TR/annotation-model/#string-body) ([cql](example7.cql))
  * Example 8: [Annotations without a Body](https://www.w3.org/TR/annotation-model/#cardinality-of-bodies-and-targets) ([cql](example8.cql))
  * Example 9: [Multiple Bodies or Targets](https://www.w3.org/TR/annotation-model/#cardinality-of-bodies-and-targets) ([cql](example9.cql))
  * Example 10: [Choice](https://www.w3.org/TR/annotation-model/#choice-between-bodies) ([cql](example10.cql))
  * Example 11: [Lifecycle Information](https://www.w3.org/TR/annotation-model/#lifecycle-information) ([cql](example11.cql))
  * Example 12: [Agents](https://www.w3.org/TR/annotation-model/#agents) ([cql](example12.cql))
  * Example 13: [Audience](https://www.w3.org/TR/annotation-model/#intended-audience) ([cql](example13.cql))
  * Example 14: [Accessibility](https://www.w3.org/TR/annotation-model/#accessibility-of-content) ([cql](example14.cql))
  * Example 15: Motivation and Purpose
  * Example 16: Rights
  * Example 17: Other Identities
  * Example 18: Resource with Purpose
  * Example 19: Selectors
  * Example 20: Fragment Selector
  * Example 21: CSS Selector
  * Example 22: XPath Selector
  * Example 23: Text Quote Selector
  * Example 24: Text Position Selector
  * Example 25: Data Position Selector
  * Example 26: SVG Selector
  * Example 27: SVG Selector, embedded
  * Example 28: Range Selector
  * Example 29: Refinement of Selection
  * Example 30: State
  * Example 31: Time State
  * Example 32: HTTP Request State
  * Example 33: Refinement of States
  * Example 34: CSS Style
  * Example 35: CSS Style, embedded
  * Example 36: Rendering Software
  * Example 37: Scope
  * Example 38: Annotation Collection
  * Example 39: Annotation Page
  * Example 40: Annotation Collection with Embedded Page
  * Example 41: Complete Example
  * Example 42: Composite
  * Example 43: List
  * Example 44: Independents
