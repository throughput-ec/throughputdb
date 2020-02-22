#' @param x R library name.

callapi <- function(x) {
  searcher <- paste0('q=library(',x,')+in:file+language:R+extension:R+extension:Rmd')

  page = 1
  per_page = 20

  call <- httr::GET('https://api.github.com/search/code',
    query = paste0(searcher, '&page=', page, '&per_page=', per_page),
    add_headers(headers))

  if(!headers(call)$status == "200 OK") {
    stop('Blew the rate limiter')
  }

  cat(sprintf("Total results found for %s: %d\n", x, content(call)$total_count))

  result <- content(call)$items

  while(length(result) < content(call)$total_count) {
    Sys.sleep(1)
    page = page + 1
    subcall <- httr::GET('https://api.github.com/search/code',
      query = paste0(searcher, '&page=', page, '&per_page=', per_page),
      add_headers(headers))

    if('retry-after' %in% names(headers(subcall))) {
      # Triggered the abuse mechanism, github tells us how long to wait.
      page <- page - 1
      cat(sprintf('\nBlocked, waiting %s seconds.\n', headers(subcall)$`retry-after`))
      Sys.sleep(as.numeric(headers(subcall)$`retry-after`))
    } else {
      result <- list(result, content(subcall)$items) %>%
        unlist(recursive = FALSE)
        cat('.')
    }
  }
  cat('\n')

  result_df <- result  %>%
    map(function(x){
      input <- x$repository
      data.frame(id=ifelse(is.null(input$id),NA,input$id),
                 name=ifelse(is.null(input$name),NA,input$name),
                 url=ifelse(is.null(input$html_url),NA,input$html_url),
                 description = ifelse(is.null(input$description),NA,input$description),
                 stringsAsFactors=FALSE)
               }) %>%
                 bind_rows() %>%
      distinct(name, .keep_all=TRUE)

  return(result_df)
}
