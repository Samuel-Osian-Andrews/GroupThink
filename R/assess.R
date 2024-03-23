#' Scan specified columns for unique responses.
#'
#' @param df A dataframe or tibble.
#' @param cols A column index or vector of column indices.
#' @export
#' @import dplyr
#' @import tidyr
assess <- function(df, cols) {
  # Ensure cols is a vector, even if it's just 1
  cols <- as.vector(cols)

  cols_names <- names(df)[cols]

  cat("\n\nExamining the following columns:\n\n")

  # Construct and print a message with both original indices and names
  for (i in seq_along(cols)) {
    cat(sprintf("Column [%d]: %s\n", cols[i], cols_names[i]))
  }

  # Show unique responses across all questions
  processed_df <- df %>%
    tidyr::pivot_longer(all_of(cols_names),
                        names_to = "Question", values_to = "Response")

  unique_responses <- unique(processed_df$Response)

  # Count the number of unique responses
  num_unique_responses <- length(unique_responses)

  # Print the number of unique responses found
  cat(sprintf("\n\n%d unique responses were found across these columns. Please make sure each response\nbelow is accounted for within your `unify()` function call:\n\n\n", num_unique_responses))

  # Print each unique response on a new line
  cat(paste(sort(as.vector(unique_responses), na.last = TRUE),
            collapse = "\n"), "\n")

  return(invisible())
}