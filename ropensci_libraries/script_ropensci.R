library(purrr)
library(dplyr)
library(jsonlite)
library(neo4r)
library(httr)

source('./R/callapi.R')

linkropen <- readr::read_file("cql/link_ropensci.cql")

con_list <- jsonlite::fromJSON('../connect_remote.json')[2,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = unlist(con_list$user),
  password = unlist(con_list$password)
)

ropensci_registry <- jsonlite::fromJSON("https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/registry.json")

packages <- ropensci_registry$packages %>%
  filter(status == "active")

gh_token <- scan('./../gh.token', what = 'character')

headers <- c(Accept='application/vnd.github.v3+json',
            Authorization=paste0('token ', gh_token[3]))

if('all_github.rds' %in% list.files('data')) {

  test_pks <- readRDS('data/all_github.rds')
  all_good <- TRUE

} else {
  test_pks <- list()

  script_home <- 'https://github.com/throughput-ec/throughputdb/blob/master/populate/case_study.Rmd'

  for (i in 1:nrow(packages)) {

    # I had to serialize this to avoid getting caught by GitHub's abuse detection.

    x <- packages[i,]

    if (!length(test_pks) >= i) {
      Sys.sleep(5) # This is probably longer than it needs to be. . .

      test_pks[[i]] <- list(package = x$name,
                            result = try(list(callapi(x$name, libCall = TRUE),
                                              callapi(x$name, libCall = FALSE))))

      if(!'try-error' %in% class(test_pks[[i]]$result)) {
        annotation_text <- paste0("The GitHub repository uses the package ",
                                  x$name, " in a `library()` or `require()` call.")

        results <- test_pks[[i]]$result %>% bind_rows()

        for(j in 1:nrow(results)) {

          sprintf(linkropen,
            results$id[j],
            results$name[j],
            results$url[j],
            ifelse(is.na(results$description[j]), "",results$description[j]),
            x$name,
            x$keywords,
            x$url,
            ifelse(is.na(x$description), "",x$description),
            annotation_text) %>%
            map(function(x) call_neo4j(con, query=.))
        }
      }
    }
    saveRDS(test_pks, 'all_github.rds')
  }
}
