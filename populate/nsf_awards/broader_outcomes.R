library(purrr)
library(dplyr)
library(jsonlite)
library(neo4r)
library(httr)
library(xml2)

con_list <- jsonlite::fromJSON('../connect_remote.json')[1,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = unlist(con_list$user),
  password = unlist(con_list$password)
)

query <- "MATCH (di:Division)
          WHERE di.Division = 'Directorate For Geosciences'
          WITH di
          MATCH (di)<-[:Program_of]-(p:Program)-[]-(o:OBJECT)-[:Year_Started]-(y:Year)
          WHERE o.description CONTAINS('broader impacts') AND NOT o.description CONTAINS('broader impacts review criteria')
          RETURN DISTINCT o.name, o.description, p.Text, di.Division, y.Year, COLLECT(o.AwardID) AS awards
          ORDER BY SIZE(awards) DESC"

aa <- call_neo4j(con, query=query, type="row", output = "json")

awards <- jsonlite::fromJSON(aa)[[1]][[1]]  %>% 
  map(function(x) {
    data.frame(title = x[[1]],
               year = x[[5]],
               awardid = paste(x[[6]], collapse = ", "),
               description = x[[2]],
               program = x[[3]],
               division = x[[4]],
               stringsAsFactors = FALSE)
  }) %>%
  bind_rows()
