#' Aggregate survey data into a tidy format.
#'
#' @param df A dataframe or tibble.
#' @param cols A column index or vector of column indices.
#' @param ... Groups of character vectors containing responses to be aggregated together. Each group is a named list of responses.
#' @param ignore A character vector of responses to be ignored from the table and calculations.
#' @return An aggregated table of responses within specified groups.
#' @export
gather <- function(df, cols, ..., ignore = NULL,
                   terminal = FALSE) {
  cols_names <- names(df)[cols]
  
  # Process grouping arguments
  groups <- list(...)
  if (!is.null(ignore)) {
    groups$Ignore <- ignore
  }
  
  # Ensure the order of groups reflects the order in the function arguments
  group_order <- names(groups)
  
  # Check for unaccounted responses. Throw error if any are found.
  all_responses <- unique(unlist(lapply(df[cols], unique)))
  grouped_responses <- unique(unlist(groups))
  unaccounted_responses <- setdiff(all_responses, grouped_responses)
  if (length(unaccounted_responses) > 0) {
    stop("The following responses are not accounted for in the provided groups: ", 
         paste(shQuote(unaccounted_responses), collapse = ", "), 
         ". Please check your grouping arguments.")
  }
  
  # Recategorize specified columns based on groups
  df[cols] <- lapply(df[cols], function(col) {
    sapply(col, function(response) {
      found_group <- NA
      for (group_name in names(groups)) {
        if (response %in% groups[[group_name]]) {
          found_group <- group_name
          break
        }
      }
      return(found_group)
    })
  })
  
  # Wrangle the data into a tidy format, calculating proportions
  
  processed_df <- df %>%
    tidyr::pivot_longer(cols_names, names_to = "question", values_to = "response") %>%
    filter(!is.na(response) & response != "Ignore") %>%
    mutate(question = factor(question, levels = cols_names))

  # **Important Change**: Explicitly order 'response' based on the specified group order
  # Do this immediately after pivot and filtering to ensure correct level ordering
  processed_df$response <- factor(processed_df$response, levels = group_order)
  
  processed_df <- processed_df %>%
    dplyr::group_by(question, response) %>%
    dplyr::count() %>%
    dplyr::ungroup() %>%
    dplyr::group_by(question) %>%
    dplyr::mutate(proportion = round(n / sum(n) * 100, 1)) %>%
    dplyr::ungroup()

  # Display the table
  if (!terminal) {
    processed_df %>% gt::gt()
  } else {
    print(processed_df)
  }
}