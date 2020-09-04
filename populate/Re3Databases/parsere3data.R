library(jsonlite)
library(neo4r)
library(xml2)
library(dplyr)
library(readr)
library(purrr)
library(cld3)

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

import <- readr::read_file("cql/linkdbs.cql")

failures <- list()

con_list <- jsonlite::fromJSON('../connect_remote.json')[2,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = unlist(con_list$user),
  password = unlist(con_list$password)
)

for(i in 1:nrow(all_repos)) {
  cat("Running ", i, "  of ", nrow(all_repos), "\n")

  has_match <- paste0("MATCH (n:OBJECT {id:'",all_repos$id[i],"'}) RETURN COUNT(n) AS count") %>%
    call_neo4j(con) %>%
    unlist()

  test_run <- try(call_repo(all_repos$id[i], re3api_short))

  if (has_match == 0) {

    if ("try-error" %in% class(test_run)) {
      failures[[length(failures) + 1 ]] <- data.frame(id = all_repos$id[i],
                                                      error = as.character(test_run),
                                                      stringsAsFactors = FALSE)
    } else {
      sprintf(import,
              test_run$id,
              test_run$name,
              test_run$url,
              test_run$keywords,
              gsub("'|\"", "", test_run$description)) %>%
        call_neo4j(con)
    }
  }

  test_run <- try(call_repo(all_repos$id[i], re3api_short))

  if (!"try-error" %in% class(test_run)) {

    lang <- strsplit(test_run$lang, ",") %>% unlist

    for(j in lang) {
      inset <- paste0("MATCH (ln:LANGUAGE {code:'",j,"'}) RETURN COUNT(ln)") %>%
        call_neo4j(con) %>%
        unlist()

      if (inset > 0) {
        runreturn <- paste0("MATCH (o:OBJECT {id:'",test_run$id,"'})
         MATCH (ln:LANGUAGE {code:'",j,"'})
         WITH o, ln
         MERGE (o)-[hln:hasLanguage]-(ln)
         ON CREATE SET hln.created = timestamp()
         RETURN hln.created;") %>%
             call_neo4j(con)
        if(length(runreturn$hln.created) > 0) {
          cat(paste0(" Added language '", j, "' to ", test_run$name, "\n"))
        } else {
          cat('Failed to create language link to ', test_run$name, "\n")
        }
      }
    }
  }
}

failures %>%
  bind_rows() %>%
  readr::write_csv("failed_archives.csv")
