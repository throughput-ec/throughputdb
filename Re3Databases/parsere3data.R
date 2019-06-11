library(jsonlite)
library(neo4r)
library(xml2)
library(dplyr)

re3api_full <- "https://www.re3data.org/api/v1/repositories"
re3api_short <- "https://www.re3data.org/api/beta/repository/"

all_repos <- xml2::read_xml(re3api_full) %>%
  xml2::as_list() %>%
  unlist(recursive = FALSE)

repo <- list()

call_repo <- function(x) {

  small_repos <- xml2::read_xml(paste0(re3api_short, all_repos[[x]]$id)) %>%
    xml2::as_list() %>%
    unlist(recursive = FALSE)

  all_kw <- names(small_repos$re3data.repository) == "keyword"
  keywords <- paste0(unlist(small_repos$re3data.repository[all_kw]), collapse = ",")

  out <- try(data.frame(name = unlist(small_repos$re3data.repository$repositoryName),
                   url = unlist(small_repos$re3data.repository$repositoryURL),
                   keywords = keywords,
                   id = unlist(small_repos$re3data.repository$re3data.orgIdentifier),
                   description = unlist(small_repos$re3data.repository$description),
                   stringsAsFactors = FALSE))

 if("try-error" %in% class(out)) {
   out <- data.frame(name = unlist(all_repos[[x]]$name),
                     url = unlist(all_repos[[x]]$id),
                     stringsAsFactors = FALSE)
 }
 return(out)
}

for(i in 1:length(all_repos)) {
  cat("Running ", i, "  of ", length(all_repos), "\n")
  test_run <- try(call_repo(i))
  if ("try-error" %in% class(test_run)) {
    repo[[i]] <- data.frame(name = unlist(all_repos[[i]]$name),
                            url = unlist(all_repos[[i]]$id),
                            stringsAsFactors = FALSE)
  } else {
    repo[[i]] <- test_run
  }


}

all_repo <- repo %>% bind_rows()

con_list <- jsonlite::fromJSON('../connect_remote.json')

con <- neo4j_api$new(
  url = paste0("http://localhost:", con_list$r_port),
  user = con_list$user,
  password = con_list$password
)

import <- readr::read_file("cql/linkdbs.cql")

for(i in 1:length(repo)) {
  call <- sprintf(import, all_repo$id[i], all_repo$name[i], all_repo$url[i], all_repo$keywords[i], all_repo$description[i])
  call %>% call_neo4j(con)
}
