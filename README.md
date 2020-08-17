
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
#> 2 C1705908     patient     patient   FALSE
#> 3 C1578481     patient     patient   FALSE
#> 4 C1578485     patient     patient   FALSE
#> 5 C1578486     patient     patient   FALSE
#> 6 C0011847    diabetes     diabete   FALSE
#> 7 C0011849    diabetes     diabete   FALSE
#> 8 C2316787 CKD stage 3 ckd stage 3   FALSE
#> 9 C0020538         HTN         htn    TRUE
```

## Using the mtsamples dataset

``` r
data(mtsamples)

str(mtsamples[1:5,])
#> 'data.frame':    5 obs. of  6 variables:
#>  $ note_id          : int  1 2 3 4 5
#>  $ description      : chr  "A 23-year-old white female presents with complaint of allergies." "Consult for laparoscopic gastric bypass." "Consult for laparoscopic gastric bypass." "2-D M-Mode. Doppler." ...
#>  $ medical_specialty: chr  "Allergy / Immunology" "Bariatrics" "Bariatrics" "Cardiovascular / Pulmonary" ...
#>  $ sample_name      : chr  "Allergic Rhinitis" "Laparoscopic Gastric Bypass Consult - 2" "Laparoscopic Gastric Bypass Consult - 1" "2-D Echocardiogram - 1" ...
#>  $ transcription    : chr  "SUBJECTIVE:,  This 23-year-old white female presents with complaint of allergies.  She used to have allergies w"| __truncated__ "PAST MEDICAL HISTORY:, He has difficulty climbing stairs, difficulty with airline seats, tying shoes, used to p"| __truncated__ "HISTORY OF PRESENT ILLNESS: , I have seen ABC today.  He is a very pleasant gentleman who is 42 years old, 344 "| __truncated__ "2-D M-MODE: , ,1.  Left atrial enlargement with left atrial diameter of 4.7 cm.,2.  Normal size right and left "| __truncated__ ...
#>  $ keywords         : chr  "allergy / immunology, allergic rhinitis, allergies, asthma, nasal sprays, rhinitis, nasal, erythematous, allegr"| __truncated__ "bariatrics, laparoscopic gastric bypass, weight loss programs, gastric bypass, atkin's diet, weight watcher's, "| __truncated__ "bariatrics, laparoscopic gastric bypass, heart attacks, body weight, pulmonary embolism, potential complication"| __truncated__ "cardiovascular / pulmonary, 2-d m-mode, doppler, aortic valve, atrial enlargement, diastolic function, ejection"| __truncated__ ...
```

## Binding UMLS Concept Unique Identifiers to a Data Frame

This function binds columns containing concept unique identifiers with
which scispacy has 99% confidence of being present with values
containing frequencies. Negated concepts, as identified by negspacy’s
NegEx implementation, are ignored and do not count towards the
frequencies.

``` r
mtsamples_with_cuis = bind_clinspacy(mtsamples[1:5,], text = 'description')

str(mtsamples_with_cuis)
#> 'data.frame':    5 obs. of  14 variables:
#>  $ note_id          : int  1 2 3 4 5
#>  $ description      : chr  "A 23-year-old white female presents with complaint of allergies." "Consult for laparoscopic gastric bypass." "Consult for laparoscopic gastric bypass." "2-D M-Mode. Doppler." ...
#>  $ medical_specialty: chr  "Allergy / Immunology" "Bariatrics" "Bariatrics" "Cardiovascular / Pulmonary" ...
#>  $ sample_name      : chr  "Allergic Rhinitis" "Laparoscopic Gastric Bypass Consult - 2" "Laparoscopic Gastric Bypass Consult - 1" "2-D Echocardiogram - 1" ...
#>  $ transcription    : chr  "SUBJECTIVE:,  This 23-year-old white female presents with complaint of allergies.  She used to have allergies w"| __truncated__ "PAST MEDICAL HISTORY:, He has difficulty climbing stairs, difficulty with airline seats, tying shoes, used to p"| __truncated__ "HISTORY OF PRESENT ILLNESS: , I have seen ABC today.  He is a very pleasant gentleman who is 42 years old, 344 "| __truncated__ "2-D M-MODE: , ,1.  Left atrial enlargement with left atrial diameter of 4.7 cm.,2.  Normal size right and left "| __truncated__ ...
#>  $ keywords         : chr  "allergy / immunology, allergic rhinitis, allergies, asthma, nasal sprays, rhinitis, nasal, erythematous, allegr"| __truncated__ "bariatrics, laparoscopic gastric bypass, weight loss programs, gastric bypass, atkin's diet, weight watcher's, "| __truncated__ "bariatrics, laparoscopic gastric bypass, heart attacks, body weight, pulmonary embolism, potential complication"| __truncated__ "cardiovascular / pulmonary, 2-d m-mode, doppler, aortic valve, atrial enlargement, diastolic function, ejection"| __truncated__ ...
#>  $ C0009818         : num  0 1 1 0 0
#>  $ C0020517         : num  1 0 0 0 0
#>  $ C0277786         : num  1 0 0 0 0
#>  $ C0554756         : num  0 0 0 1 0
#>  $ C1705052         : num  0 0 0 1 0
#>  $ C3864418         : num  1 0 0 0 0
#>  $ C4039248         : num  0 1 1 0 0
#>  $ C4331911         : num  0 0 0 1 0
```
