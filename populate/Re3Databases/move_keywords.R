library(jsonlite)
library(neo4r)
library(xml2)
library(dplyr)
library(readr)
library(purrr)
library(cld3)

con_list <- jsonlite::fromJSON('../connect_remote.json')[2,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = unlist(con_list$user),
  password = unlist(con_list$password)
)

query <- 'MATCH (n:OBJECT) WHERE exists(n.keywords)
          RETURN id(n) AS id'

add_kw <- readr::read_file("cql/addkeywords.cql")

get_keys <- query %>%
  call_neo4j(con) %>%
  pluck("id") %>%
  unlist() %>%
  map(function(x) {
    addkw <- sprintf(add_kw, x)
    result <- addkw %>%
      call_neo4j(con, output="json") %>%
      fromJSON() %>%
      bind_rows() %>%
      pluck("row") %>%
      unlist(recursive = FALSE)
    return(data.frame(keywords = result[[1]],
                      object = result[[2]],
                      stringsAsFactors = FALSE))
  }) %>%
  bind_rows()

readr::write_csv(get_keys, "keyword_output.csv")
