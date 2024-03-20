readme
================

## Introduction and Install

GroupThink is a package designed to assist in the analysis in
categorical survey data. It currently has two functions:`unify()` and
`assess()` (though others are planned for the future!).

GroupThink isn’t on CRAN, so you’ll need to use `devtools` to install
it. Run:

``` r
#install.packages("devtools") # ...uncomment line if needed
library(devtools)

devtools::install_github("Samuel-Osian-Andrews/GroupThink")
library(GroupThink)
```

You only need to do this once. After that, you can just run
`library(GroupThink)` like you would for any other package. As
GroupThink is still in development, you should periodically install the
package again in order to get updates.

GroupThink depends on `dplyr`, `tidyr` and `gt` libraries. If these
aren’t automatically installed, you may need to run:

``` r
#install.packages(c("dplyr", "tidyr", "gt")) # ...uncomment line if needed
```

## GroupThink ‘at a glance’

The `unify()` function groups together Likert-style responses for a
given question or set of questions, returning a summarised output that
contains the n and proportion for each of these groupings.

``` r
unify(data, cols = 1, # ...the name of your dataframe and column(s) to analyse
      
      # Below, we 'group' responses via custom grouping labels (e.g. 'Agree'):
      Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somewhat disagree", "Strongly disagree"),
      Neutral = "Neither agree nor disagree",

      ignore = "Don't know") # ...optionally, set response(s) to ignore from calcs
```

    ## Error in unify(data, cols = 1, Agree = c("Somewhat agree", "Strongly agree"), : The following responses are not accounted for in the provided groups: 'Entirely agree', 'NA', 'Entirely disagree', 'Neutral'. Please check your grouping arguments.

To view all column index numbers for your data frame, you can run
`colnames` from base-R.

``` r
colnames(data)
```

    ## [1] "I find the course material engaging and relevant."    
    ## [2] "The course workload is manageable within my schedule."
    ## [3] "Feedback from assignments is helpful for my learning."

You might also find it beneficial to run GroupThink’s `assess()`
function, which provides an overview of the different response options
in your specified columns and also provides missing data analysis.

``` r
assess(data, cols = c(1, 2, 3))
```

    ## 
    ## 
    ## Examining the following columns:
    ## 
    ## Column [1]: I find the course material engaging and relevant.
    ## Column [2]: The course workload is manageable within my schedule.
    ## Column [3]: Feedback from assignments is helpful for my learning.
    ## 
    ## 
    ## 17 unique responses were found across these columns. Please make sure each response
    ## below is accounted for within your `unify()` function call:
    ## 
    ## 
    ## Agree
    ## Disagree
    ## Don't know
    ## Entirely agree
    ## Entirely disagree
    ## Highly agree
    ## Highly disagree
    ## Indifferent
    ## Neither agree nor disagree
    ## Neutral
    ## No opinion
    ## Somewhat agree
    ## Somewhat disagree
    ## Strongly agree
    ## Strongly disagree
    ## Unsure
    ## NA

These grouped responses can be renamed into anything you like. For
example, `Agree` could instead be `Positive`, `Good`, `Satisifed` or
something else entirely. Similarly, `Don't know` could be its own group,
instead of being ignored. You may include as many custom groups as you’d
like.

There’s of course nothing stopping you from having just 1 response
option per group (e.g. `"Somewhat agree" = "Somewhat agree"`). The main
purpose of `unify()` is that it forces you to be *intentional* with how
you handle your data, to improve consistency and avoid mistakes.

If you forgot to include a response in your custom groupings, `unify()`
will throw an error. This makes it *much* harder to make an error in the
‘n’ and ‘proportion’ calculations. For example:

``` r
unify(data, 1, Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somewhat disagree", "Strongly disagree"),
      Neutral = "Neither agree nor disagree")
```

    ## Error in unify(data, 1, Agree = c("Somewhat agree", "Strongly agree"), : The following responses are not accounted for in the provided groups: "Entirely agree", "NA", "Entirely disagree", "Neutral", "Don't know". Please check your grouping arguments.

``` r
      #ignore = "Don't know" -- let's stop unify() from seeing this line
```

As seen above, the output tells you that you forgot to assign “Don’t
know” to a grouping variable.

## Data for unify()

The `unify()` function expects data that looks like this:

    ## # A tibble: 10 × 3
    ##    I find the course material en…¹ The course workload …² Feedback from assign…³
    ##    <fct>                           <fct>                  <fct>                 
    ##  1 Somewhat disagree               Agree                  Disagree              
    ##  2 Entirely agree                  Disagree               <NA>                  
    ##  3 Somewhat agree                  <NA>                   Disagree              
    ##  4 Somewhat disagree               Unsure                 Disagree              
    ##  5 <NA>                            Disagree               Strongly agree        
    ##  6 Entirely agree                  <NA>                   <NA>                  
    ##  7 Entirely disagree               Neither agree nor dis… Strongly agree        
    ##  8 Somewhat agree                  Highly disagree        Strongly agree        
    ##  9 Somewhat disagree               Neither agree nor dis… Strongly disagree     
    ## 10 Somewhat agree                  Neither agree nor dis… Agree                 
    ## # ℹ abbreviated names: ¹​`I find the course material engaging and relevant.`,
    ## #   ²​`The course workload is manageable within my schedule.`,
    ## #   ³​`Feedback from assignments is helpful for my learning.`

Responses do not need to be consistently labelled either within or
between different questions/columns, and can contain missing data
(you’ll likely want to assign `NA` to the ignore parameter).

## Benefits of `unify()`

`unify()` is a response to key bottlenecks and common mistakes when
analysing survey data. The function is beneficial because it…

- **Allows for easy groupings.** `unify()` makes it very easy to group
  together different Likert-style responses (e.g. combining
  `Somewhat agree` with `Strongly agree`, or `Excellent` and
  `Very good`). It’s now *very* difficult to make mistakes with
  incorrect groupings, as `unify()` will alert you of any unassigned
  responses.
- **Automates your calculations.** `unify()` handles n and proportion
  calculations for you, meaning you no longer have to undertake complex
  data manipulation tasks using functions such as `pivot_longer()`,
  which can result in inaccurate results if you’re not careful!
- **Works with full questions as column headers**. Typically, exporting
  survey responses (such as from Microsoft Forms or SurveyMonkey) will
  leave you with full questions (e.g. “Do you agree or disagree that…”)
  as column headers. This is usually a nightmare to work with in R.
  Because `unify()` works on column indexes, rather than column names,
  you don’t need to worry about recoding your columns or typing out full
  questions each time.
- **Gives usable outputs**. `unify()` neatly integrates with ggplot,
  allowing you to visualise your aggregated data. Alternatively, you can
  produce formatted tables through the gtTable argument.
- **Presents clear, readable syntax**. Even for those unfamiliar with R
  syntax, `unify()` makes it very clear exactly how you’ve grouped
  together your responses, improving readability and reproducibility.
- **Means faster insights**. With just a few lines of code, this
  function could save you hours worth of work for large survey projects.

## Further functionality

#### Aggregate across multiple columns/questions

You are not restricted to analysing just one question/column with
`unify()`. You can specify multiple columns/questions to use for the
output:

``` r
unify(data, c(1, 6, 7), # ...use columns 1, 6 and 7.
      Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somwewhat disagree", "Strongly disagree"),
      Neither = "Neither agree nor disagree")
```

    ## Error in `df[cols]`:
    ## ! Can't subset columns past the end.
    ## ℹ Locations 6 and 7 don't exist.
    ## ℹ There are only 3 columns.

#### Handle inconsistent labeling between columns/questions.

Likert-style questions can take different forms. For example, one
question might be on an **Agree/Disagree** scale, another **Good/Poor**
and another might also use Good/Poor, but with **different
capitalisations**.

`unify()` is very flexible to this; you don’t need to worry about all
response options being in each question/column, and can just code in
each kind of response.

``` r
unify(data, c(1, 8, 9),
      Positive = c("Somewhat agree", "Strongly agree",
                   "Good", "Very good",
                   "Very Good"), # ...notice different capitalisation!
      
      Negative = c("Somewhat disagree", "Strongly disagree",
                   "Poor", "Very poor",
                   "Very Poor"), # ...again, different capitalisation
      
      Neither = "Neither agree nor disagree")
```

    ## Error in `df[cols]`:
    ## ! Can't subset columns past the end.
    ## ℹ Locations 8 and 9 don't exist.
    ## ℹ There are only 3 columns.

#### Filter out responses from the output only

If you want to only include only some response groups in the output but
not from the calculations, we can use the `filter` argument.

``` r
unify(data, 1,
      Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somwewhat disagree", "Strongly disagree"),
      Neither = "Neither agree nor disagree",
      
      filter = "Agree") # ...only include the Agree group in the output
```

    ## Error in unify(data, 1, Agree = c("Somewhat agree", "Strongly agree"), : The following responses are not accounted for in the provided groups: "Somewhat disagree", "Entirely agree", "NA", "Entirely disagree", "Neutral", "Don't know". Please check your grouping arguments.

The other variable groupings are used for the calculations, but only
“Agree” responses are shown in the final output.

#### Integrate with ggplot

Unless you’ve set `unify()`’s gt_table() argument to `TRUE`, it will
output as a tibble. This means it integrates neatly into `ggplot()`
function calls.

Let’s pretend we’ve already run `unify()` and assigned it to the name
`united`…

    ## Error in unify(data, c(1, 2, 3)): The following responses are not accounted for in the provided groups: "Somewhat disagree", "Entirely agree", "Somewhat agree", "NA", "Entirely disagree", "Neutral", "Don't know", "Agree", "Disagree", "Unsure", "Neither agree nor disagree", "Highly disagree", "Highly agree", "Strongly agree", "Strongly disagree", "No opinion", "Indifferent". Please check your grouping arguments.

``` r
ggplot(data = united, # ...unify() output becomes ggplot()'s data argument
       aes(x = Response, y = Proportion)) +
  geom_bar() +
  theme_minimal()
```

    ## Error in eval(expr, envir, enclos): object 'united' not found

## Even more functionality

For other functionality not covered in this document, please run
`?unify()` and `?assess()` to view the help file, which covers all
function parameters.

## Future plans

- Add support for `stargazer` tables into `unify()`.

- Develop a separate function for analysing multiple choice data for
  data formats typical of exported survey data.

I’d love to know what changes you’d like to see! If you have an idea for
either an existing function or a new function altogether - or would like
to collaborate - please let me know here!

## Bug reports and feature requests

Please do let me know any issues you come across, or ideas you have for
either exising function or even new ones!

You can use the Issues tab on GitHub for bug reports, and the Discussion
tab for feature requests.
