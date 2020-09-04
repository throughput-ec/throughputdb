#' @param x R library name.

callapi <- function(x, libCall = TRUE) {

  if(libCall) {
    searcher <- paste0('q="library(',x,')"+in:file+language:R+extension:R+extension:Rmd')
  } else {
    searcher <- paste0('q="require(',x,')"+in:file+language:R+extension:R+extension:Rmd')
  }

  problems <- list()
  page = 1
  per_page = 20

  limited <- TRUE
  counter <- 1

  while(limited) {
    call <- httr::GET('https://api.github.com/search/code',
      query = paste0(searcher, '&page=', page, '&per_page=', per_page),
      add_headers(headers))

    if(!headers(call)$status == "200 OK" & 'retry-after' %in% names(headers(call))) {
      cat(sprintf('\nBlocked, waiting %s seconds.\n', headers(call)$`retry-after`))
      Sys.sleep(as.numeric(headers(call)$`retry-after`))
      counter <- counter + 1
    } else {
      limited <- FALSE
    }

    if(counter > 10){
      stop("Tried 10 times, you're cooked.")
    }
  }

  cat(sprintf("Total results found for %s: %d\n", x, content(call)$total_count))

  result <- content(call)$items

  outputsize <- content(call)$total_count

  if  (!is.null(result) & !is.null(outputsize)) {
    counter <- 1
    page <- page + 1

    while ((length(result) < outputsize) | (((page + 1) * per_page) <= outputsize)) {
      Sys.sleep(1)
      subcall <- httr::GET('https://api.github.com/search/code',
        query = paste0(searcher, '&page=', page, '&per_page=', per_page),
        add_headers(headers))

      if('retry-after' %in% names(headers(subcall))) {
        # Triggered the abuse mechanism, github tells us how long to wait.
        cat(sprintf('\nBlocked, waiting %s seconds.\n', headers(subcall)$`retry-after`))
        Sys.sleep(as.numeric(headers(subcall)$`retry-after`))
      } else {
        if (stringr::str_detect(headers(subcall)$status, "^200")) {
          if(length(content(subcall)$items) == 0) {
            break
          }
          result <- list(result, content(subcall)$items) %>%
            unlist(recursive = FALSE)
          cat('Page', page, 'of', ceiling(outputsize / per_page), 'for', x, '.\n')
          page <- page + 1
        } else {
          cat("\nSomethings up:", headers(subcall)$status, "\n")
          problems[[page]] <- subcall
          saveRDS(problems, "problems.RDS")
          if (page > 50) {
            break
          }
        }
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
  } else {
    stop("There's a problem with the call.")
  }
}
