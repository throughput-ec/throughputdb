#  Add annotation that Goring knows all datasets were included from Blois et al.
#' @title Link Records
#' @description Links records within the graph database using an annotation model.
#' @author Simon Goring
#' @param creator A list containing (at minimum) a single element, representing a person.
#' @param body An (optional) object of class \code{object}, with parameters \code{type} and \code{body}.
#' @param body_rel An (optional) object of class \code{object}, which acts as a parent for the body element, for example, a database from which the \code{body} is drawn.
#' @param target The \code{object} that is being annotated.  May be a single object or a list of \code{object}s.
#' @param target_rel An (optional) object of class \code{object}, which acts as a parent for the body element, for example, a database from which the \code{body} is drawn.
#' @description This function generates a graph that links bodies to targets, and adds the resources from which the post is made.
#' @importFrom assertthat::assert_that
#' @import RNeo4j
#' 
link_record <- function(creator, 
                        body = NULL, 
                        body_rel = NULL, 
                        target, 
                        target_rel = NULL, 
                        source = NULL,
                        body_composite = FALSE,
                        con) {

  assertthat::assert_that(is(creator, "list"))
  assertthat::assert_that(is(body, "list") | is.null(body))
  assertthat::assert_that(is(target, "list"))
  
  # Person attributes:
  # identifier, affiliation, familyName, givenName
  # MUST HAVE identifier, which is type list with PropertyID & URL, which is of schema type "PropertyValue"
  
  assertthat::assert_that(all(hasName(creator, c('URL', 'PropertyID'))))

  neo_trans <- newTransaction(con)
    
  create_time <- Sys.Date()
  uid <- as.character(runif(1, min = 0, max = 1e7))
               
  # We know, for W3C that any annotation node has the type: oa:Annotation
  # Allows for one or multiple creators.  Currently no author order is supported, but
  # could be added as an "order" parameter in the `created` field.
  
  query_cre <- "MERGE  (ann:annotation {created:{create_time}, uid:{uid}})
                MERGE  (cre:creator {id: {URL}, 
                                     PropertyID:{PropertyID},
                                     firstName:{firstName},
                                     lastName:{lastName}})
                MERGE (cre)-[:created]->(ann)"

  if (class(creator) == 'list' & !'list' %in% sapply(creator, class)) {
    creator$create_time <- create_time
    creator$uid         <- uid
    
    appendCypher(neo_trans, query_cre, creator)
    
  } else {
    for (i in 1:length(creator)) {
      creator[[i]]$create_time <- create_time
      creator[[i]]$uid         <- uid
      
      appendCypher(neo_trans,
                   query_cre,
                   creator[[i]])
    }
  }

  # Add the body element, one or multiple supported.  As per the W3C parameters there
  # is no order in the body elements.
  
  add_body <- "MERGE (bod:object {type: {type}, value:{value}})
               MERGE (ann:annotation {created:{create_time}, uid:{uid}})
               MERGE (bod)<-[:hasBody]-(ann)"
  
  if (!is.null(body)) {
    if (!all("body" %in% names(body))) {
      
      body$create_time <- create_time
      body$uid         <- uid
      
      appendCypher(neo_trans,
                   add_body,
                   body)
      
    } else {
      for (i in 1:length(body)) {
        body[[i]]$create_time <- create_time
        body[[i]]$uid         <- uid
        
        appendCypher(neo_trans,
                     add_body,
                     body[[i]])
      }
    }
  }
  
  add_target <- "MERGE (tar:object {type: {type}, value:{value}})
                 MERGE (ann:annotation {created:{create_time}, uid:{uid}})
                 MERGE (tar)<-[:hasTarget]-(ann)
                 MERGE (res:object {type: {type_r}, value:{value_r}, class: 'Resource'})
                 MERGE (tar)-[:hasRes]->(res)"
  
  if (!is.null(target)) {
    if (!all("target" %in% names(target))) {
      
      target$create_time <- create_time
      target$uid         <- uid
      target$type_r      <- source$type
      target$value_r     <- source$value
      
      appendCypher(neo_trans,
                   add_target,
                   target)
      
    } else {
      for (i in 1:length(target)) {
        target[[i]]$create_time <- create_time
        target[[i]]$uid         <- uid
        target[[i]]$type_r      <- source$type
        target[[i]]$value_r     <- source$value
        
        appendCypher(neo_trans,
                     add_target,
                     target[[i]])
      }
    }
  }
  
  commit(neo_trans)

}
