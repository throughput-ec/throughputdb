library(jsonlite)
library(neo4r)
library(xml2)
library(dplyr)
library(readr)
library(purrr)

con_list <- jsonlite::fromJSON('../connect_remote.json')[2,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = 'neo4j',
  password = 'test'
)

re3api_full <- "https://www.re3data.org/api/v1/repositories"
re3api_short <- "https://www.re3data.org/api/beta/repository/"

cat("Calling re3data for full repo list\n")

all_repos <- xml2::read_xml(re3api_full) %>%
  xml2::as_list() %>%
  unlist(recursive = FALSE) %>%
  purrr::map(function(x) data.frame(id = unlist(x$id),
                                    name = unlist(x$name),
                                    stringsAsFactors = FALSE)) %>%
  bind_rows()

source("R/call_repo.R")

httr::set_config(httr::user_agent("goring@wisc.edu;
     +http://github.com/throughput-ec/throughputdb/Re3Databases"))

for (i in 1:nrow(all_repos)) {

  test_run <- try(call_repo(all_repos$id[i], re3api_short))

  if (!"try-error" %in% class(test_run)) {

    if(test_run$lang == "") {
      cat("No supported language for ", test_run$name, "\n")
    } else {
      query <- 'MATCH (n:OBJECT {id: "%s"})
                MATCH (l:LANGUAGE {code: "%s"})
                WITH n,l
                MERGE (n)-[hl:hasLanguage]->(l)
                ON CREATE SET hl.created = timestamp()'
      langs <- strsplit(test_run$lang, ",")[[1]]
      sapply(langs, function(x) {
        sprintf(query, test_run$id, x) %>%
        call_neo4j(con)
      })
    }
  } else {
    cat("No supported language for ", test_run$name, "\n")
  }
}
