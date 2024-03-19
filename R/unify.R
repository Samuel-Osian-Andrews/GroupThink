#' Aggregate survey data into a tidy format.
#'
#' @param df A dataframe or tibble.
#' @param cols A column index or vector of column indices.
#' @param ... Groups containing a string or string vector conforming to responses in the specified column(s).
#' @param ignore A string or string vector of responses to be ignored from the table and calculations.
#' @param filter A string or string vector of responses to filter for the output.
#' @param gtTable A logical value indicating whether to output as a gt table.
#' @param colSplit A logical value indicating whether to split responses into separate columns in the output.
#' @param hideResponse A logical value indicating whether to hide the response field from the output.
#' @param hideN A logical value indicating whether to hide the n field from the output.
#' @param hideProportion A logical value indicating whether to hide the proportion field from the output.
#' @return An aggregated table of responses within specified groups.
#' @export
#' @import dplyr
#' @import tidyr
#' @import gt
unify <- function(df, # ...dataframe to process
                   cols, # ...columns index(es) to process
                   ..., # ... specify groups to recategorise responses
                   ignore = NULL, # ...responses to ignore from calculations
                   filter = NULL, # ...responses to filter for the output
                   gtTable = FALSE, # ...whether outputs as a gt table
                   colSplit = FALSE, # ...split responses into separate columns
                   hideResponse = FALSE, # ...hide response from output
                   hideN = FALSE, # ...hide n from output
                   hideProportion = FALSE) # ...hide proportion from output
{

  # Stop user from specifying both colSplit and hideResponse options
  if (colSplit & hideResponse) {
    stop("Both colSplit and hideResponse options are set to TRUE.
    Splitting by columns demands that the response field is kept.")
  }

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
  
  # Recategorise specified columns based on groups
  df[cols] <- lapply(df[cols], function(col) {
    sapply(col, function(Response) {
      found_group <- NA
      for (group_name in names(groups)) {
        if (Response %in% groups[[group_name]]) {
          found_group <- group_name
          break
        }
      }
      return(found_group)
    })
  })
  
  # Wrangle the data into a tidy format, calculating proportions
  
  processed_df <- df %>%
    tidyr::pivot_longer(cols_names, names_to = "Question", values_to = "Response") %>%
    dplyr::filter(!is.na(Response) & Response != "Ignore") %>%
    dplyr::mutate(question = factor(Question, levels = cols_names))

  # Explicitly order 'response' based on the specified group order
  # ...Do this immediately after pivot and filtering to ensure correct level ordering
  processed_df$Response <- factor(processed_df$Response, levels = group_order)

  processed_df <- processed_df %>%
    dplyr::group_by(Question, Response) %>%
    dplyr::count() %>%
    dplyr::ungroup() %>%
    dplyr::group_by(Question) %>%
    dplyr::mutate(Proportion = round(n / sum(n) * 100, 1)) %>%
    dplyr::ungroup()

  # Apply filter if specified
  if (!is.null(filter)) {
    processed_df <- processed_df %>%
      filter(Response %in% filter)
  }

  if (colSplit) {
    # Spread responses to wide format
    processed_df <- processed_df %>%
      tidyr::pivot_wider(names_from = Response,
                         values_from = c(n, Proportion),
                         names_glue = "{Response} ({.value})")
  }

  # Remove the Response column if specified
  if (hideResponse & !colSplit) {
    processed_df <- processed_df %>%
      select(-Response)
  }

  # Hide n if specified
  if (hideN & !colSplit) {
    processed_df <- processed_df %>%
      select(-n)
  } else if (hideN & colSplit) {
    processed_df <- processed_df %>%
    # Remove n and Proportion columns
      select(-contains("(n)"))
  }

  # Hide Proportion if specified
  if (hideProportion & !colSplit) {
    processed_df <- processed_df %>%
      select(-Proportion)
  } else if (hideProportion & colSplit) {
    processed_df <- processed_df %>%
    # Remove n and Proportion columns
      select(-contains("(Proportion)"))
  }

  # Display the tibble or gt table
  if (gtTable) {
    processed_df %>% gt::gt()
  } else {
    print(processed_df)
  }
}