GroupThink
================

![Banner image for GroupThink package](https://github.com/Samuel-Osian-Andrews/GroupThink/blob/main/readme_files/GroupThink_narrow.png)

## Introduction and Install

GroupThink is a package designed to assist in the analysis in
categorical survey data. It mainly acts as an interface for existing
`tidyverse` functions - but makes it easier to aggregate responses, do
cross-question analysis, and avoid classic mistakes typical of survey
data analysis.

It currently has two functions:`unify()` and `assess()` (though others
are planned for the future…!).

GroupThink isn’t on CRAN, so you’ll need to use `devtools` to install
it. Run:

``` r
install.packages("devtools")
library(devtools)

devtools::install_github("Samuel-Osian-Andrews/GroupThink")
library(GroupThink)
```

As GroupThink is still in development, you should periodically reinstall
the package to get updates.

### Dependencies

GroupThink depends on `dplyr`, `tidyr` and `gt` libraries. If these
aren’t installed automatically when you install GroupThink, you may need
to run:

``` r
install.packages(c("dplyr", "tidyr", "gt"))
```

## Benefits of GroupThink

GroupThink is a response to key bottlenecks and common mistakes when
analysing survey data. The function is beneficial because it…

- **Allows for easy groupings.** `unify()` makes it very easy to group
  together different Likert-style responses (e.g. combining
  `Somewhat agree` with `Strongly agree`, or `Excellent` and
  `Very good`). It’s now extremely difficult to make mistakes with
  incorrect groupings, as `unify()` alerts you of any unassigned
  responses.

- **Automates your calculations.** `unify()` handles n and proportion
  calculations for you, meaning you no longer have to undertake complex
  data manipulation tasks, avoiding functions such as `pivot_longer()`,
  which can result in inaccurate figures if you’re not careful!

- **Works with full questions as column headers.** Typically, exporting
  survey responses (such as from Microsoft Forms or SurveyMonkey) will
  leave you with full questions (e.g. “Do you agree or disagree that…”)
  as column headers. This is usually a nightmare to work with in R.
  Because `unify()` works on column indexes, rather than column names,
  you don’t need to worry about recoding your columns or typing out full
  survey questions throughout your code.

- **Gives usable outputs.**. `unify()` neatly integrates with ggplot,
  allowing you to visualise your aggregated data. Alternatively, you can
  produce formatted tables through the gtTable argument.

- **Presents clear, readable syntax.** Even for those unfamiliar with R
  syntax, `unify()` makes it very clear exactly how you’ve grouped
  together your responses, improving readability and reproducibility.

- **Means faster insights.** With just a few lines of code, this
  function could save you hours worth of work for large survey projects.

## Core functionality

### The `unify()` function

The `unify()` function groups together Likert-style responses for a
given question or set of questions, returning a summarised output that
contains the n and proportion for each of these groupings.

``` r
unify(data, cols = 1, # ...dataframe name and column index number(s) to analyse
      
      # Below, we 'group' responses via custom grouping labels (e.g. 'Agree'):
      Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somewhat disagree", "Strongly disagree"),
      Neutral = "Neither agree nor disagree",

      ignore = "Don't know") # ...optionally, set response(s) to ignore from calcs
```

    ## # A tibble: 1 × 7
    ##   Question         `Agree (n)` `Disagree (n)` `Neutral (n)` `Agree (Proportion)`
    ##   <chr>                  <int>          <int>         <int>                <dbl>
    ## 1 I find the cour…          38             32            18                 43.2
    ## # ℹ 2 more variables: `Disagree (Proportion)` <dbl>,
    ## #   `Neutral (Proportion)` <dbl>

The grouping labels can be anything you like. For example, `Agree` could
instead be `Positive`, `Good`, `Satisifed` or something else entirely.
Similarly, `Don't know` could be its own group, instead of being
ignored. You may include as many grouping labels as you’d like.

There’s of course nothing wrong with having just 1 response option per
group (e.g. `"Somewhat agree" = "Somewhat agree"`). The main purpose of
`unify()` is that it forces you to be **intentional** with how you
handle your data, to improve consistency and avoid mistakes.

### Left out responses

If you forgot to include a response in your custom groupings, `unify()`
will throw an error. This is crucial for avoiding mistakes in your
proportion calculations. For example:

``` r
unify(data, 1, Agree = "Somewhat agree",
                #"Strongly agree"), -- let's stop unify() from seeing this line
      Disagree = c("Somewhat disagree", "Strongly disagree"),
      Neutral = "Neither agree nor disagree",
      ignore = "Don't know") 
```

    ## Error in unify(data, 1, Agree = "Somewhat agree", Disagree = c("Somewhat disagree", : The following responses are not accounted for in the provided groups: 'Strongly agree'. Please check your grouping arguments.

As seen above, the output tells you that you forgot to assign “Strongly
agree” to a grouping variable.

These errors are crucial, since other R functions do not warn you if you
haven’t accounted for a group, or mistyped “Strongly **A**gree”, as
“Strongly **a**gree”, for example.

### Data for unify()

The `unify()` function expects data that looks like this:

    ## # A tibble: 10 × 3
    ##    I find the course material en…¹ The course workload …² Feedback from assign…³
    ##    <fct>                           <fct>                  <fct>                 
    ##  1 Somewhat disagree               Agree                  Disagree              
    ##  2 Strongly agree                  Disagree               No opinion            
    ##  3 Somewhat agree                  Agree                  <NA>                  
    ##  4 Somewhat disagree               Unsure                 Disagree              
    ##  5 Somewhat agree                  <NA>                   Strongly agree        
    ##  6 Strongly agree                  Neither agree nor dis… <NA>                  
    ##  7 Strongly disagree               Neither agree nor dis… Strongly agree        
    ##  8 Somewhat agree                  Highly disagree        Strongly agree        
    ##  9 Somewhat disagree               Neither agree nor dis… Strongly disagree     
    ## 10 Somewhat agree                  Neither agree nor dis… Agree                 
    ## # ℹ abbreviated names: ¹​`I find the course material engaging and relevant.`,
    ## #   ²​`The course workload is manageable within my schedule.`,
    ## #   ³​`Feedback from assignments is helpful for my learning.`

Responses do not need to be consistently labelled either within or
between different questions/columns, and can contain missing data
(you’ll likely want to assign `NA` to the ignore parameter).

### View column index numbers

Since GroupThink functions work with column **index numbers**, not
column names, you’ll likely want to summarise all index numbers of your
dataset. For this, run `colnames()` from base-R.

``` r
colnames(data)
```

    ## [1] "I find the course material engaging and relevant."    
    ## [2] "The course workload is manageable within my schedule."
    ## [3] "Feedback from assignments is helpful for my learning."

## The `assess()` function

You might find it beneficial to run GroupThink’s `assess()` function,
which provides an overview of the different response options in your
specified columns.

``` r
assess(data, cols = c(2, 3))
```

    ## Examining the following columns:
    ## 
    ## Column [2]: The course workload is manageable within my schedule.
    ## Column [3]: Feedback from assignments is helpful for my learning.
    ## 
    ## 
    ## 11 unique responses were found across these columns. Please make sure each response
    ## below is accounted for within your `unify()` function call:
    ## 
    ## 
    ## Agree
    ## Disagree
    ## Highly agree
    ## Highly disagree
    ## Indifferent
    ## Neither agree nor disagree
    ## No opinion
    ## Strongly agree
    ## Strongly disagree
    ## Unsure
    ## NA

## Further functionality

#### Aggregate across multiple columns/questions

You are not restricted to analysing just one question/column with
`unify()`. You can specify multiple columns/questions to use for the
output:

``` r
unify(data, c(1, 2, 3), # ...analyse Columns 1, 2 and 3
      Positive = c("Somewhat agree", "Strongly agree", "Highly agree", "Agree"),
      Negative = c("Somewhat disagree", "Strongly disagree", "Highly disagree",
                   "Disagree"),
      ignore = c(NA, "Don't know", "Unsure", "Neither agree nor disagree",
                 "No opinion", "Indifferent"),
      
      hideN = TRUE) # ...(optional) hide n column from output (a lot cleaner!)
```

    ## # A tibble: 3 × 3
    ##   Question                         Positive (Proportion…¹ Negative (Proportion…²
    ##   <chr>                                             <dbl>                  <dbl>
    ## 1 Feedback from assignments is he…                   57.8                   42.2
    ## 2 I find the course material enga…                   54.3                   45.7
    ## 3 The course workload is manageab…                   36.7                   63.3
    ## # ℹ abbreviated names: ¹​`Positive (Proportion)`, ²​`Negative (Proportion)`

…Just make sure that you’ve accounted for each response option across
your range of columns, otherwise you’ll get an error.



#### Make formatted tables

Using the gtTable argument, `unify()` makes it simple to create nice,
formatted tables.

``` r
unify(data, 1, Agree = c("Somewhat agree", "Strongly agree"),
      Disagree = c("Somewhat disagree", "Strongly disagree"),
      Neutral = "Neither agree nor disagree",
      ignore = "Don't know",
      filter = c("Agree", "Disagree"),
      hideN = TRUE, # ...optionally, hide N column
      
      gtTable = TRUE) # ...set gtTable to TRUE
```

Question | Agree (Proportion) | Disagree (Proportion)
--- | --- | ---
I find the course material engaging and relevant. | 43.2 | 36.4




#### Filter out responses from the output only

If you want to only display one response option in the output, we can
use the `filter` argument.

Note that this is different from the `ignore` parameter: `filter`
removes unwanted responses *after* the calculations have been performed,
while `ignore` removes them *before*.

``` r
unify(data, 3,
      Agree = c("Agree", "Strongly agree"),
      Disagree = c("Disagree", "Strongly disagree"),
      Neither = c("No opinion", "Indifferent"),
      ignore = c(NA, "Don't know"),
      
      filter = "Agree") # ...only include the Agree group in the output
```

    ## # A tibble: 1 × 3
    ##   Question                                      `Agree (n)` `Agree (Proportion)`
    ##   <chr>                                               <int>                <dbl>
    ## 1 Feedback from assignments is helpful for my …          37                 38.9

The other variable groupings are used for the calculations, but only
“Agree” responses are shown in the final output.

#### Integrate with ggplot

Unless you’ve set `unify()`’s gt_table() argument to `TRUE`, it will
output as a tibble. This means it integrates neatly into `ggplot()`
function calls.

Let’s pretend we’ve already run `unify()` on columns 1, 2 & 3, and
assigned it to the name `united`…

``` r
ggplot(data = united, # ...unify() output becomes ggplot()'s data argument
       aes(x = Question, y = `Agree (Proportion)`, fill = Question)) +
  geom_col() +
  
  # ...below are just optional customisation options:
  coord_flip() +
  theme_bw() +
  scale_fill_manual(values = c("cornflowerblue", "coral", "chartreuse3")) +
  scale_y_continuous(limits = c(0, 70)) +
  theme(legend.position = "none")
```

![](readme_files/figure-gfm/ggplot-1.png)<!-- -->

## Even more functionality

For other functionality not covered in this document, please run
`?unify()` and `?assess()` to view the help files, which covers all
function parameters.

## Future plans

- Add support for `stargazer` tables into `unify()`.

- Develop a separate function for analysing multiple choice data for
  data formats typical of exported survey data.

## Bug reports and feature requests

Please do let me know of any issues you come across. You can use the
[Issues]([url](https://github.com/Samuel-Osian-Andrews/GroupThink/issues)) tab in GitHub for any bug reports.

If you have any ideas for existing features, or perhaps even new ones,
then I’d love to hear them. Let me know in the [Discussions]([url](https://github.com/Samuel-Osian-Andrews/GroupThink/discussions)https://github.com/Samuel-Osian-Andrews/GroupThink/discussions) tab in
GitHub.

I am also open to invitations to collaborate.
