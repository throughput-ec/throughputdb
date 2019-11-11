library(jsonlite)
library(neo4r)
library(xml2)
library(dplyr)
library(readr)
library(purrr)
library(cld3)

con_list <- jsonlite::fromJSON('../connect_remote.json')

con <- neo4j_api$new(
  url = 'localhost:7474',
  user = con_list$user,
  password = 'test'
)

query <- 'MATCH (n:OBJECT)-[:isType]-(:TYPE {type:"schema:DataCatalog"})
          RETURN n.id'

add_kw <- readr::read_file("cql/addkeywords.cql")

get_keys <- query %>%
  call_neo4j(con) %>%
  pluck("n.id") %>%
  unlist() %>%
  map(function(x) {
    addkw <- sprintf(add_kw, i)
    addkw  %>% call_neo4j(con, output="json")
  }) %>%
  bind_rows()

readr::write_csv(get_keys, "keyword_output.csv")
