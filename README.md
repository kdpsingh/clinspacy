
<!-- README.md is generated from README.Rmd. Please edit that file -->

# clinspacy

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of clinspacy is to perform biomedical named entity recognition,
Unified Medical Language System (UMLS) concept mapping, and negation
detection using the Python spaCy, scispacy, and negspacy packages.

## Installation

You can install the GitHub version of clinspacy
with:

``` r
remotes::install_github('ML4LHS/clinspacy', INSTALL_opts = '--no-multiarch')
```

## Example

``` r
library(clinspacy)

clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#>        cui      entity       lemma negated
#> 1 C0030705     patient     patient   FALSE
#> 2 C1578481     patient     patient   FALSE
#> 3 C1578484     patient     patient   FALSE
#> 4 C1550655     patient     patient   FALSE
#> 5 C1578483     patient     patient   FALSE
#> 6 C0011849    diabetes     diabete   FALSE
#> 7 C0011847    diabetes     diabete   FALSE
#> 8 C2316787 CKD stage 3 ckd stage 3   FALSE
#> 9 C0020538         HTN         htn    TRUE
```
