# Case Studies:
# 1. Jessica Blois
# 2. Simon - Baconizing
# 3. Referencing specific schema types for the target - object description as a separate body.
# 4. Collections of objects for a project
# Add a Dryad example :)
# Maybe something else from Re3Data?  - Tag a database?

library(httr)
library(gh)
library(dplyr)
library(stringi)

orcid <- data.frame(simon = "orcid.org/0000-0002-2700-4605",
                    jessica = "orcid.org/0000-0003-4048-177X")

neotoma <- "https://doi.org/10.17616/R3PD38"

# Simon finds a core:

creator <- list(URL = '0000-0002-2700-4605',
               PropertyID = 'orcid',
               firstName = 'Simon',
               lastName = 'Goring')

body <- list(type = "TextualBody",
             value = "Two samples counted at the same depth with the same ages.  These samples seem to just be multiple counts.")

target <- list(type = "URL",
               body = "http://api.neotomadb.org/v1/data/datasets/13047")


link_record(con = con, 
            creator = creator, 
            body = body, 
            target = target)

# Jessica Annotates Baconized cores:

all_neot <- neotoma::get_dataset()

all_matched <- readr::read_csv('../../stepps-baconizing/data/input/blois_files/2011-01-06-all.matched.lp.sites.csv')

ds_names <- sapply(all_neot, function(x) x$dataset.meta$collection.handle)

blois_sets <- sapply(match(all_matched$Handle, ds_names),
                     function(x) {
                       if (!is.na(x)) {
                         return(list(type = 'Dataset',
                                     value = paste0('http://api.neotomadb.org/v1/data/datasets/', 
                                       all_neot[[x]]$dataset.meta$dataset.id)))
                       } else {
                         return(NA)
                       }
                     })

names(blois_sets) <- rep('body', length(blois_sets))

for (i in length(blois_sets):1) {
  if (any(is.na(blois_sets[[i]]))) {
    blois_sets[[i]] <- NULL
  }
}

creator <- list(URL = '0000-0003-4048-177X',
                PropertyID = 'orcid',
                lastName = 'Blois',
                firstName = 'Jessica')

target <- blois_sets

body <- list(body = list(type='TextualBody',
             value ='Age models rebuilt with new biostratigraphic markers.'),
             body = list(type = 'ScholarlyArticle',
                         value='https://doi.org/10.1016/j.quascirev.2011.04.017'))

link_record(con = con, creator = creator, body = body, target = target)

# Create a new app for GitHub to search for repositories using package from neotoma, dryad. . . 
# First, search rOpenSci for all rOpenSci packages:

ropensci_registry <- fromJSON("https://raw.githubusercontent.com/ropensci/roregistry/master/registry.json")

packages <- ropensci_registry$packages$name

search_strings <- list(neotoma = list(doi = '10.17616/R3PD38',
                                      search = 'library(neotoma)+in:file+language:R'),
                       dryad = list(doi = '10.17616/R34S33',
                                    search = 'library(rdryad)+in:file+language:R'))

gh_token <- scan('gh.token', what = 'character')

test_pks <- list()

for (i in i:length(packages)) { 
  
  # I had to serialize this to avoid getting caught by GitHub's abuse detection.
  
  x <- packages[i]
  
  Sys.sleep(5) # This is probably longer than it needs to be. . . 
  
  repos <- gh(paste0('/search/code?q=library(',x,')+in:file+language:R+extension:R+extension:Rmd'), 
                   .token = gh_token)
       
  test_pks[[i]] <- list(target = lapply(unique(sapply(repos$items, function(x)x$repository$html_url)), 
                                        function(y) { list(body = y, type = 'URL')}),
                        body = list(body = lapply(paste0('http://github.com/ropensci/',x), 
                                                  function(y) { list(type = 'URL', body = y) })),
                                    body = list(type = "TextAnnotation",
                                                body = paste0("The GitHub repository uses the package ",
                                                              x," in a `library()` call.")),
                        creator = list(URL = '0000-0002-2700-4605',
                                       PropertyID = 'orcid',
                                       lastName = 'Goring',
                                       firstName = 'Simon'),
                        body_rel = list(type = 'URL',
                                        URL = 'https://ropensci.org/'))
  cat(i, '\n')
}

for(i in 1:length(test_pks)) {
  link_record(con = con,
              creator = test_pks[[i]]$creator,
              body = test_pks[[i]]$body,
              target = test_pks[[i]]$target,
              body_rel = test_pks[[i]]$body_rel)
}

results <- cypher(con, 'MATCH (bod:body)<-[:hasBody]-(:annotation)-[:hasTarget]->(n:target)<-[:hasTarget]-(:annotation)-[:hasBody]->(bod1:body) WHERE bod<>bod1 RETURN DISTINCT bod.body AS package, COLLECT(DISTINCT n.body) AS repos;')
