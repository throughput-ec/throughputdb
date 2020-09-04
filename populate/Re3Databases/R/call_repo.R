#' @title call_repo
#' @description Calls a re3data database using the short identifier.
#' @param x The repository identifier in Re3Data
#' @param re3api_short The beta API path to extract information about a re3data product.

call_repo <- function(x, re3api_short) {

  small_repos <- xml2::read_xml(paste0(re3api_short, x)) %>%
    xml2::as_list() %>%
    unlist(recursive = FALSE)

  all_kw <- names(small_repos$re3data.repository) == "keyword"
  keywords <- small_repos$re3data.repository[all_kw] %>%
    unlist %>%
    tolower %>%
    paste0(collapse = ",")

  lang_names <- names(small_repos$re3data.repository) == "repositoryLanguage"
  lang <- small_repos$re3data.repository[which(lang_names)]
  lang <- lang %>% unlist %>% paste0(collapse=",")

  description <- unlist(small_repos$re3data.repository$description)

  if (is.null(description)) {
    description <- ""
  }

  out <- try(data.frame(name = unlist(small_repos$re3data.repository$repositoryName),
                   url = unlist(small_repos$re3data.repository$repositoryURL),
                   keywords = keywords,
                   id = unlist(small_repos$re3data.repository$re3data.orgIdentifier),
                   lang = lang,
                   description = description,
                   stringsAsFactors = FALSE))

 if("try-error" %in% class(out)) {
   out <- out
 }
 return(out)
}
