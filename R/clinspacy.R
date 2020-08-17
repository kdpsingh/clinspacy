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
  reticulate::configure_environment(force = TRUE)

  if (!reticulate::py_module_available('spacy')) {
    packageStartupMessage('Spacy not found. Installing spacy...')
    reticulate::py_install('spacy', pip = TRUE)
  }

  if (!reticulate::py_module_available('scispacy')) {
    packageStartupMessage('Scispacy not found. Installing scispacy...')
    reticulate::py_install('scispacy', pip = TRUE)
  }

  if (!reticulate::py_module_available('negspacy')) {
    packageStartupMessage('Negspacy not found. Installing negspacy...')
    reticulate::py_install('negspacy', pip = TRUE)
  }

  if (!reticulate::py_module_available('en_core_sci_sm')) {
    packageStartupMessage('en_core_sci_sm language model not found. Installing en_core_sci_sm...')
    reticulate::py_install('https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.2.5/en_core_sci_sm-0.2.5.tar.gz', pip = TRUE)
  }

  packageStartupMessage('Importing spacy...')
  spacy <<- reticulate::import('spacy')
  packageStartupMessage('Importing scispacy...')
  scispacy <<-  reticulate::import('scispacy')
  packageStartupMessage('Importing negspacy...')
  negspacy <<- reticulate::import('negspacy')
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
  packageStartupMessage('\nWelcome to clinspacy. Take a look at help(clinspacy) to get started.')
}

#' Performs biomedical named entity recognition, Unified Medical Language System (UMLS)
#' concept mapping, and negation detection using the Python spaCy, scispacy, and negspacy packages.
#' This function identifies only those concept unique identifiers with with scispacy has
#' 99% confidence of being present. Negation is identified using negspacy's NegEx implementation.
#'
#' @param text A character string containing medical text that you would like to process.
#' @return A data frame containing the UMLS concept unique identifiers (cui), entities,
#' lemmatized entities, and NegEx negation status (\code{TRUE} means negated, \code{FALSE} means *not* negated).
#'
#' @examples
#' clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
clinspacy <- function(text) {
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


#' This function binds columns containing concept unique identifiers with which scispacy has
#' 99% confidence of being present with values containing frequencies. Negated concepts,
#' as identified by negspacy's NegEx implementation, are ignored and do not count towards
#' the frequencies.
#'
#' @param df A data frame.
#' @param text A character string containing the name of the column to process.
#' @return A data frame containing the original data frame as well as additional column names
#' for each UMLS concept unique identifer found with values containing frequencies.
#'
#' @examples
#' data(mtsamples)
#' mtsamples_with_cuis = bind_clinspacy(mtsamples[1:5,], text = 'description')
#' str(mtsamples_with_cuis)
bind_clinspacy <- function(df, text) {
  clinspacy_text = text
  assertthat::assert_that(assertthat::has_name(df, text))
  assertthat::assert_that(nrow(df) > 0)
  df_nrow = nrow(df)

  dt = data.table(df)[, .(clinspacy_id = 1:.N, text = get(clinspacy_text))]
  dt = dt[,clinspacy(.SD[,text]), clinspacy_id][negated == FALSE, .(clinspacy_id, cui, present = 1)]
  dt = dcast(dt, clinspacy_id ~ cui, value.var = 'present', fun.aggregate = sum)
  dt2 = data.table(clinspacy_id = 1:df_nrow)
  dt = merge(dt, dt2, all.y=TRUE)
  setnafill(dt, fill = 0, cols = 2:ncol(dt))
  dt[, clinspacy_id := NULL]
  cbind(df, as.data.frame(dt))
}

