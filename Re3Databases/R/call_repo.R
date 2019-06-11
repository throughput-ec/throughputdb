#' @title call_repo
#' @description Calls a re3data database using the short identifier.
#' @params x The index of the
call_repo <- function(x) {

  small_repos <- xml2::read_xml(paste0(re3api_short, x)) %>%
    xml2::as_list() %>%
    unlist(recursive = FALSE)

  all_kw <- names(small_repos$re3data.repository) == "keyword"
  keywords <- paste0(unlist(small_repos$re3data.repository[all_kw]), collapse = ",")
  description <- unlist(small_repos$re3data.repository$description)

  if (is.null(description)) {
    description <- ""
  }

  out <- try(data.frame(name = unlist(small_repos$re3data.repository$repositoryName),
                   url = unlist(small_repos$re3data.repository$repositoryURL),
                   keywords = keywords,
                   id = unlist(small_repos$re3data.repository$re3data.orgIdentifier),
                   description = description,
                   stringsAsFactors = FALSE))

 if("try-error" %in% class(out)) {
   out <- out
 }
 return(out)
}
