#' Aggregate survey data into a tidy format.
#'
#' @param df A dataframe or tibble.
#' @param cols A column index or vector of column indices.
#' @param ... Groups of character vectors containing responses to be aggregated together. Each group is a named list of responses.
#' @param ignore A character vector of responses to be ignored from the table and calculations.
#' @return An aggregated table of responses within specified groups.
#' @export
gather <- function(df, # ...dataframe to process
                   cols, # ...columns index(es) to process
                   ..., # ... specify groups to recategorise responses
                   ignore = NULL, # ...responses to ignore from calculations
                   filter = NULL, # ...responses to filter for the output
                   tibble = TRUE, # ...whether outputs as a tibble
                   gt_table = FALSE, # ...whether outputs as a gt table
                   col_split = FALSE, # ...split responses into separate columns
                   rm_response = FALSE) # ...remove the response column
{

  # Stop user from using both tibble and gt options
  if (tibble & gt_table) {
    stop("Both tibble and gt_table options are set to TRUE.
    Please choose either tibble or gt_table for the output, not both.")
  }

  # Check that user has supplied either tibble or gt options
  if (!tibble & !gt_table) {
    stop("Both tibble and gt_table options are set to FALSE.
    Please choose either tibble or gt_table for the output.")
  }

  # Stop user from specifying both col_split and rm_response options
  if (col_split & rm_response) {
    stop("Both col_split and rm_response options are set to TRUE.
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

  if (col_split) {
    # Spread responses to wide format
    processed_df <- processed_df %>%
      tidyr::pivot_wider(names_from = Response,
                         values_from = c(n, Proportion),
                         names_glue = "{Response} ({.value})")
  }

# Remove the Response column if specified
  if (rm_response & !col_split) {
    processed_df <- processed_df %>%
      select(-Response)
  }

  # Display the tibble
  if (!tibble) {
    processed_df %>% gt::gt()
  } else {
    print(processed_df)
  }
}