library(jsonlite)
library(RNeo4j)

ropensci_registry <- jsonlite::fromJSON("https://raw.githubusercontent.com/ropensci/roregistry/gh-pages/registry.json")

packages <- ropensci_registry$packages$name

gh_token <- scan('gh.token', what = 'character')

if('all_github.rds' %in% list.files('data')) {

  test_pks <- readRDS('data/all_github.rds')
  all_good <- TRUE

} else {
  test_pks <- list()
}

  script_home <- 'https://github.com/throughput-ec/throughputdb/blob/master/populate/case_study.Rmd'

  for (i in 1:length(packages)) {

    # I had to serialize this to avoid getting caught by GitHub's abuse detection.

    x <- packages[i]


    if (!length(test_pks) >= i) {
      Sys.sleep(5) # This is probably longer than it needs to be. . .

      repos <- gh::gh(paste0('/search/code?q=library(',x,
                             ')+in:file+language:R+extension:R+extension:Rmd'),
                       .token = gh_token)

      annotation_text <- paste0("The GitHub repository uses the package ",
                                x, " in a `library()` or `require()` call.")

      repo_list <- unique(sapply(repos$items, function(x)x$repository$html_url))

      target_list <- lapply(repo_list,
                            function(y) {
                              if(length(repo_list) > 0) {
                                return(object(value = y, type = 'URL'))
                                } else { return(NULL) }
                              }
                            )

      if (length(target_list) > 0) {

        test_pks[[i]] <- list(
          target = target_list,
          body = list(object(value = paste0('http://github.com/ropensci/',x),
                                       type = 'URL'),
                      object( type = "annotationText",
                             value = annotation_text),
                      object(type = 'URL',
                            value = script_home)),
          generator = creator(identifier = '0000-0002-2700-4605',
                                      PropertyID = 'orcid',
                                        lastName = 'Goring',
                                     firstName = 'Simon'),
                body_rel = object(type = 'URL',
                                 value = 'https://ropensci.org/'),
                source = object(type = 'URL',
                                value = 'http://github.com'))
    } else {
      test_pks[[i]] <- list()
    }
  }

  if (length(test_pks[[i]]) > 0) {

    link_record(con,
                target = test_pks[[i]]$target,
                  body = test_pks[[i]]$body,
             generator = test_pks[[i]]$generator,
              body_rel = test_pks[[i]]$body_rel,
                source = test_pks[[i]]$source)
  }

  saveRDS(object = test_pks, file = 'data/all_github.rds')
  cat(i, '\n')
}
