# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

spacy <- NULL
scispacy <- NULL
negspacy <- NULL
nlp <- NULL
negex <- NULL
linker <- NULL

.onLoad <- function(libname, pkgname) {
  reticulate::configure_environment(pkgname)
  packageStartupMessage('Importing spacy...')
  spacy <<- reticulate::import('spacy', delay_load = TRUE)
  packageStartupMessage('Importing scispacy...')
  scispacy <<-  reticulate::import('scispacy', delay_load = TRUE)
  packageStartupMessage('Importing negspacy...')
  negspacy <<- reticulate::import('negspacy', delay_load = TRUE)
  packageStartupMessage('Loading the en_core_sci_sm language model...')
  nlp <<- spacy$load("en_core_sci_sm")
  packageStartupMessage('Loading NegEx...')
  negex <<- negspacy$negation$Negex(nlp)
  packageStartupMessage('Loading the UMLS entity linker... (this may take a while)')
  linker <<- scispacy$linking$EntityLinker(resolve_abbreviations=TRUE, name="umls", threshold = 0.99)
  packageStartupMessage('Adding the UMLS entity linker and NegEx to the spacy pipeline...')
  nlp$add_pipe(linker)
  nlp$add_pipe(negex, last=TRUE)
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage('\nWelcome to medspacy. Take a look at help(medspacy) to get started.')
}

#' Performs biomedical named entity recognition, Unified Medical Language System (UMLS)
#' concept mapping, and negation detection using the Python spaCy, scispacy, and negspacy packages.
#'
#' @param text A character string containing medical text that you would like to process.
#' @return A data frame containing the UMLS concept unique identifiers (cui), entities,
#' lemmatized entities, and NegEx negation status (\code{TRUE} means negated, \code{FALSE} means *not* negated).
#'
#' @examples
#' medspacy('This patient has diabetes and CKD stage 3 but no HTN.')
medspacy <- function(text) {
  parsed_text = nlp(text)
  entity_nums = length(parsed_text$ents)

  return_df = data.frame(cui = character(0),
                         entity = character(0),
                         lemma = character(0),
                         negated = logical(0),
                         stringsAsFactors = FALSE)

  for (entity_num in seq_len(entity_nums)) {
    if (is.null(unlist(parsed_text$ents[[entity_num]]$`_`$kb_ents))) next

    temp_cuis = parsed_text$ents[[entity_num]]$`_`$kb_ents
    temp_cuis = unlist(temp_cuis)
    temp_df = data.frame(cui = temp_cuis[seq(1, length(temp_cuis), by = 2)], stringsAsFactors = FALSE)

    temp_df$entity = parsed_text$ents[[entity_num]]$text
    temp_df$lemma = parsed_text$ents[[entity_num]]$lemma_
    temp_df$negated = parsed_text$ents[[entity_num]]$`_`$negex

    return_df = rbind(return_df, temp_df)
  }

  return_df
}



