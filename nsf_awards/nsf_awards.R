library(purrr)
library(dplyr)
library(jsonlite)
library(neo4r)
library(httr)
library(xml2)

source('R/bind_to_file.R')
query <- readr::read_file('cql/parameterized.cql')

con_list <- jsonlite::fromJSON('../connect_remote.json')[1,]

con <- neo4j_api$new(
  url = paste0(con_list$host, ":", con_list$r_port),
  user = unlist(con_list$user),
  password = unlist(con_list$password)
)

nsfawards <- list.files('data/input/awards',
                        full.names = TRUE,
                        include.dirs = FALSE)

for (i in 1:length(nsfawards)) {

  unzip <- list.files('data/input/awards/unzip',
                      full.names = TRUE,
                      include.dirs = FALSE)

  if(length(unzip) > 0) {
    unlink(unzip)
  }

  cat(sprintf("\n***\nUnzipping %s\n", nsfawards[i]))
  unzip(nsfawards[i], exdir = 'data/input/awards/unzip')
  unzippers <- list.files('data/input/awards/unzip', full.names = TRUE)

  big_table <- list()
  cat(sprintf("\nBinding %d files\n", length(unzippers)))

  to_df <- function(x){
    df <- bind_to_file(x)

    if('try-error' %in% class(df)) {
      return(df)
    }

    df[is.na(df)] <- "None"
    colnames(df) <- gsub("\\.", "", colnames(df))
    return(df)
  }

  for(j in 1:length(unzippers)) {
    run_df <- try(to_df(unzippers[j]))
    if('try-error' %in% class(run_df)) {
        big_table[[j]] <- NULL
        file.copy(unzippers[j], to = 'data/output/errors/')
    } else {
        big_table[[j]] <- run_df
    }

    cat('.')
    if (j%%50 == 0) {
      cat('', j, '\n')
    }
  }

  cat('\n')

  datecheck <- function(x) {
    res <- (is.null(x) | is.na(x) | x %in% c("NA", "None"))
    x[res] <- "0/0/0"
    return(x)
  }

  years <- big_table  %>%
    bind_rows() %>%
    mutate_at(vars(contains("Date")), datecheck) %>%
    readr::write_csv(., path=paste0('data/output/awards_',i,'.csv'))

  years[is.na(years)] <- "None"

  cat(sprintf('\nRunning query for the %dth file from NSF: %s\n',
              i, nsfawards[i]))

  cat(sprintf('\nA total of %d award files to be run against.\n*****\n',
              length(unzippers)))
  query <- readr::read_file('cql/parameterized.cql')
  for(j in 1:nrow(years)) {
    aa <- as.list(years[j,]) %>%
      glue_data(query, .open="|", .close="|") %>%
      call_neo4j(con, query=.)
  }

  unlink(unzippers)
}
