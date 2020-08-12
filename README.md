
<!-- README.md is generated from README.Rmd. Please edit that file -->

# medspacy

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of medspacy is to perform biomedical named entity recognition,
Unified Medical Language System (UMLS) concept mapping, and negation
detection using the Python spaCy, scispacy, and negspacy packages.

## Installation

You can install the GitHub version of medspacy with:

``` r
remotes::install_github('ML4LHS/medspacy')
```

## Example

``` r
library(medspacy)
#> Importing spacy...
#> Importing scispacy...
#> Importing negspacy...
#> Loading the en_core_sci_sm language model...
#> Loading NegEx...
#> Loading the UMLS entity linker... (this may take a while)
#> Adding the UMLS entity linker and NegEx to the spacy pipeline...
#> 
#> Welcome to medspacy. Take a look at help(medspacy) to get started.

medspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#>        cui      entity       lemma negated
#> 1 C0030705     patient     patient   FALSE
#> 2 C1578486     patient     patient   FALSE
#> 3 C1705908     patient     patient   FALSE
#> 4 C1578483     patient     patient   FALSE
#> 5 C1550655     patient     patient   FALSE
#> 6 C0011847    diabetes     diabete   FALSE
#> 7 C0011849    diabetes     diabete   FALSE
#> 8 C2316787 CKD stage 3 ckd stage 3   FALSE
#> 9 C0020538         HTN         htn    TRUE
```
