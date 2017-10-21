library(testthat)
library(RNeo4j)
library(jsonlite)

pass <- readr::read_lines('../auth.log')

con <- RNeo4j::startGraph("http://localhost:17474/db/data/", username = pass[1], pass[2])

#  Add annotation that Goring knows all datasets were included from Blois et al.
#' @title Link Records
#' @description Links records within the graph database using an annotation model.
#' @author Simon Goring
#' @param creator A list containing (at minimum)
link_record <- function(creator, 
                        body = NULL, 
                        body_rel = NULL, 
                        target, 
                        target_rel = NULL, 
                        con) {

  assertthat::assert_that(is(creator, "list"))
  assertthat::assert_that(is(body, "list") | is.null(body))
  assertthat::assert_that(is(target, "list"))
  
  # Person attributes:
  # identifier, affiliation, familyName, givenName
  # MUST HAVE identifier, which is type list with PropertyID & URL, which is of schema type "PropertyValue"
  
  assertthat::assert_that(all(hasName(creator, c('URL', 'PropertyID'))))
  
  # We know, for W3C that any annotation node has the type: oa:Annotation
  annotation <- createNode(con, "annotation",
                           created=Sys.time())
  
  person <- getOrCreateNode(con, "creator",
                       creator)
  
  created <- createRel(person, "created", annotation)
  
  # Manage the body:
  if (!is.null(body)) {
    if (!all("body" %in% names(body))) {
      bodynode <- createNode(con, "body", body)
      createRel(annotation, "hasBody", bodynode)
    } else {
      bodies <- lapply(body, 
                       function(x) {
                         if('list' %in% class(x) & length(x) == 1) {
                            bodynode <- createNode(con, "body", x[[1]])
                         } else {
                           bodynode <- createNode(con, "body", x)
                         }
                         createRel(annotation, "hasBody", bodynode)
                         if (!is.null(body_rel)) {
                           # We've added a related DB:
                           bodyRel_node <- getOrCreateNode(con, 'related', body_rel[2:1])
                           createRel(bodynode, 'relatedTo', bodyRel_node)
                         }
                       })
    }
  }
  
  if ('type' %in% names(target)) {
      targetnode <- getOrCreateNode(con, "target", target)
      createRel(annotation, "hasTarget", targetnode)
  } else {
    lapply(target,
           function(x) {
             if('list' %in% class(x) & length(x) == 1) {
               targetnode <- getOrCreateNode(con, "target", x[[1]])
             } else {
               targetnode <- getOrCreateNode(con, "target", x)
             }
             createRel(annotation, "hasTarget", targetnode)
             if (!is.null(target_rel)) {
               # We've added a related DB:
               tarRel_node <- getOrCreateNode(con, 'related', target_rel)
               createRel(targetNode, 'relatedTo', tarRel_node)
             }
           })
  }
}
