# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

# spacy <- NULL
# scispacy <- NULL
# negspacy <- NULL
# nlp <- NULL
# negex <- NULL
# linker <- NULL

clinspacy_env = new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # reticulate::configure_environment(force = TRUE)
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage('Welcome to clinspacy.')
  packageStartupMessage('By default, this package will install and use miniconda and create a "clinspacy" conda environment.')
  packageStartupMessage('If you want to override this behavior, use clinspacy_init(miniconda = FALSE) and specify an alternative environment using reticulate::use_python() or reticulate::use_conda().')
}


#' Initializes clinspacy. This function is optional to run but gives you more control over
#' the parameters used by scispacy at initiation. If you do not run this function, it will be
#' run with default parameters the first time that any of the package functions are run.
#'
#' @param miniconda Defaults to TRUE, which results in miniconda being installed (~400 MB)
#' and configured with the "clinspacy" conda environment. If you want to override this behavior,
#' set \code{miniconda} to \code{FALSE} and specify an alternative environment using use_python()
#' or use_conda().
#' @param use_linker Defaults to \code{FALSE}. To turn on the UMLS linker, set this to \code{TRUE}.
#' @param linker_threshold Defaults to 0.99. This arguemtn is only relevant if \code{use_linker}
#' is set to \code{TRUE}. It refers to the confidence threshold value used by the scispacy UMLS entity
#' linker. Note: This can be lower than the \code{threshold} from \code{\link{clinspacy_init}}).
#' The linker_threshold can only be set once per session.
#' @param ... Additional settings available from: \href{https://github.com/allenai/scispacy}{https://github.com/allenai/scispacy}.

clinspacy_init <- function(miniconda = TRUE, use_linker = FALSE, linker_threshold = 0.99, ...) {

  assertthat::assert_that(assertthat::is.flag(miniconda))
  assertthat::assert_that(assertthat::is.flag(use_linker))

  if (use_linker) {
    assertthat::assert_that(linker_threshold >= 0.70 & linker_threshold <= 0.99)
  }

  # If clinspacy has already been initialized without a linker and you now want to add a linker
  if (!is.null(clinspacy_env$nlp)) {
    if (clinspacy_env$use_linker == FALSE & use_linker == TRUE) {
      clinspacy_env$use_linker <- use_linker
      message('Loading the UMLS entity linker... (this may take a while)')
      clinspacy_env$linker <- clinspacy_env$scispacy$linking$EntityLinker(resolve_abbreviations=TRUE,
                                                                          name="umls",
                                                                          threshold = linker_threshold, ...)
      message('Adding the UMLS entity linker to the spacy pipeline...')
      clinspacy_env$nlp$add_pipe(clinspacy_env$linker)
      return()
    }
    stop('Clinspacy has already been initialized. To re-initialize clinspacy, you must restart your R session.')
  }

  # If clinspacy has not been initialized previously

  message('Initializing clinspacy using clinspacy_init()...')

  clinspacy_env$use_linker <- use_linker

  message('Checking if the cui2vec_embeddings.rda dataset has been downloaded...')

  tryCatch({
    system.file('data', 'cui2vec_embeddings.rda', package='clinspacy', mustWork = TRUE)
  }, error = function (e) {
    download.file('https://github.com/ML4LHS/clinspacy/releases/download/v0.1.0/cui2vec_embeddings.rda',
    file.path(system.file('data', package='clinspacy', mustWork = TRUE), 'cui2vec_embeddings.rda'))
  })

  if (miniconda) {
    message('Checking if miniconda is installed...')
    tryCatch(reticulate::install_miniconda(),
             error = function (e) {NULL})

    # By now, miniconda should be installed. Let's check if the clinspacy environment is configured
    is_clinspacy_env_installed = tryCatch(reticulate::use_miniconda(condaenv = 'clinspacy', required = TRUE),
                                          error = function (e) {'not installed'})

    if (!is.null(is_clinspacy_env_installed)) { # this means the 'clinspacy' condaenv *is not* installed
      message('Clinspacy requires the clinspacy conda environment. Attempting to create...')
      reticulate::conda_create(envname = 'clinspacy')
    }

    # This is intentional -- will throw an error if environment creation failed
    reticulate::use_miniconda(condaenv = 'clinspacy', required = TRUE)
  }

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

  if (!reticulate::py_module_available('en_core_sci_lg')) {
    packageStartupMessage('en_core_sci_lg language model not found. Installing en_core_sci_lg...')
    reticulate::py_install('https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.2.5/en_core_sci_lg-0.2.5.tar.gz', pip = TRUE)
  }

  message('Importing spacy...')
  clinspacy_env$spacy <- reticulate::import('spacy', delay_load = TRUE)
  message('Importing scispacy...')
  clinspacy_env$scispacy <-  reticulate::import('scispacy', delay_load = TRUE)
  message('Importing negspacy...')
  clinspacy_env$negspacy <- reticulate::import('negspacy', delay_load = TRUE)

  message('Loading the en_core_sci_lg language model...')
  clinspacy_env$nlp <- clinspacy_env$spacy$load("en_core_sci_lg")
  message('Loading NegEx...')
  clinspacy_env$negex <- clinspacy_env$negspacy$negation$Negex(clinspacy_env$nlp)

  if (use_linker) {
    message('Loading the UMLS entity linker... (this may take a while)')
    clinspacy_env$linker <- clinspacy_env$scispacy$linking$EntityLinker(resolve_abbreviations=TRUE,
                                           name="umls",
                                           threshold = linker_threshold, ...)
    message('Adding the UMLS entity linker to the spacy pipeline...')
    clinspacy_env$nlp$add_pipe(clinspacy_env$linker)
  }

  message('Adding NegEx to the spacy pipeline...')
  clinspacy_env$nlp$add_pipe(clinspacy_env$negex)
}

#' Performs biomedical named entity recognition, Unified Medical Language System (UMLS)
#' concept mapping, and negation detection using the Python spaCy, scispacy, and negspacy packages.
#' This function identifies only those concept unique identifiers with with scispacy has
#' 99 percent confidence of being present. Negation is identified using negspacy's NegEx implementation.
#'
#' @param text A character string containing medical text that you would like to process.
#' @param threshold Defaults to 0.99. The confidence threshold value used by clinspacy (can be higher than the
#' \code{linker_threshold} from \code{\link{clinspacy_init}}). Note that whereas the
#' linker_threshold can only be set once per session, this threshold can be updated during the R session.
#' @param semantic_types Character vector containing any combination of the following:
#' c("Acquired Abnormality", "Activity", "Age Group", "Amino Acid Sequence", "Amino Acid, Peptide, or Protein", "Amphibian", "Anatomical Abnormality", "Anatomical Structure", "Animal", "Antibiotic", "Archaeon", "Bacterium", "Behavior", "Biologic Function", "Biologically Active Substance", "Biomedical Occupation or Discipline", "Biomedical or Dental Material", "Bird", "Body Location or Region", "Body Part, Organ, or Organ Component", "Body Space or Junction", "Body Substance", "Body System", "Carbohydrate Sequence", "Cell", "Cell Component", "Cell Function", "Cell or Molecular Dysfunction", "Chemical", "Chemical Viewed Functionally", "Chemical Viewed Structurally", "Classification", "Clinical Attribute", "Clinical Drug", "Conceptual Entity", "Congenital Abnormality", "Daily or Recreational Activity", "Diagnostic Procedure", "Disease or Syndrome", "Drug Delivery Device", "Educational Activity", "Element, Ion, or Isotope", "Embryonic Structure", "Entity", "Environmental Effect of Humans", "Enzyme", "Eukaryote", "Event", "Experimental Model of Disease", "Family Group", "Finding", "Fish", "Food", "Fully Formed Anatomical Structure", "Functional Concept", "Fungus", "Gene or Genome", "Genetic Function", "Geographic Area", "Governmental or Regulatory Activity", "Group", "Group Attribute", "Hazardous or Poisonous Substance", "Health Care Activity", "Health Care Related Organization", "Hormone", "Human", "Human-caused Phenomenon or Process", "Idea or Concept", "Immunologic Factor", "Indicator, Reagent, or Diagnostic Aid", "Individual Behavior", "Injury or Poisoning", "Inorganic Chemical", "Intellectual Product", "Laboratory or Test Result", "Laboratory Procedure", "Language", "Machine Activity", "Mammal", "Manufactured Object", "Medical Device", "Mental or Behavioral Dysfunction", "Mental Process", "Molecular Biology Research Technique", "Molecular Function", "Molecular Sequence", "Natural Phenomenon or Process", "Neoplastic Process", "Nucleic Acid, Nucleoside, or Nucleotide", "Nucleotide Sequence", "Occupation or Discipline", "Occupational Activity", "Organ or Tissue Function", "Organic Chemical", "Organism", "Organism Attribute", "Organism Function", "Organization", "Pathologic Function", "Patient or Disabled Group", "Pharmacologic Substance", "Phenomenon or Process", "Physical Object", "Physiologic Function", "Plant", "Population Group", "Professional or Occupational Group", "Professional Society", "Qualitative Concept", "Quantitative Concept", "Receptor", "Regulation or Law", "Reptile", "Research Activity", "Research Device", "Self-help or Relief Organization", "Sign or Symptom", "Social Behavior", "Spatial Concept", "Substance", "Temporal Concept", "Therapeutic or Preventive Procedure", "Tissue", "Vertebrate", "Virus", "Vitamin")
#' @param return_scispacy_embeddings Defaults to \code{FALSE}. This is primarily intended for
#' use by the \code{\link{bind_clinspacy_embeddings}} function to obtain scispacy embeddings.
#' @param verbose Defaults to TRUE.
#' @return A data frame containing the UMLS concept unique identifiers (cui), entities,
#' lemmatized entities, and NegEx negation status (\code{TRUE} means negated, \code{FALSE} means *not* negated).
#'
#' @examples
#' clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
clinspacy <- function(text, threshold = 0.99,
                      semantic_types = c("Acquired Abnormality",
                                         "Activity",
                                         "Age Group",
                                         "Amino Acid Sequence",
                                         "Amino Acid, Peptide, or Protein",
                                         "Amphibian",
                                         "Anatomical Abnormality",
                                         "Anatomical Structure",
                                         "Animal",
                                         "Antibiotic",
                                         "Archaeon",
                                         "Bacterium",
                                         "Behavior",
                                         "Biologic Function",
                                         "Biologically Active Substance",
                                         "Biomedical Occupation or Discipline",
                                         "Biomedical or Dental Material",
                                         "Bird",
                                         "Body Location or Region",
                                         "Body Part, Organ, or Organ Component",
                                         "Body Space or Junction",
                                         "Body Substance",
                                         "Body System",
                                         "Carbohydrate Sequence",
                                         "Cell",
                                         "Cell Component",
                                         "Cell Function",
                                         "Cell or Molecular Dysfunction",
                                         "Chemical",
                                         "Chemical Viewed Functionally",
                                         "Chemical Viewed Structurally",
                                         "Classification",
                                         "Clinical Attribute",
                                         "Clinical Drug",
                                         "Conceptual Entity",
                                         "Congenital Abnormality",
                                         "Daily or Recreational Activity",
                                         "Diagnostic Procedure",
                                         "Disease or Syndrome",
                                         "Drug Delivery Device",
                                         "Educational Activity",
                                         "Element, Ion, or Isotope",
                                         "Embryonic Structure",
                                         "Entity",
                                         "Environmental Effect of Humans",
                                         "Enzyme",
                                         "Eukaryote",
                                         "Event",
                                         "Experimental Model of Disease",
                                         "Family Group",
                                         "Finding",
                                         "Fish",
                                         "Food",
                                         "Fully Formed Anatomical Structure",
                                         "Functional Concept",
                                         "Fungus",
                                         "Gene or Genome",
                                         "Genetic Function",
                                         "Geographic Area",
                                         "Governmental or Regulatory Activity",
                                         "Group",
                                         "Group Attribute",
                                         "Hazardous or Poisonous Substance",
                                         "Health Care Activity",
                                         "Health Care Related Organization",
                                         "Hormone",
                                         "Human",
                                         "Human-caused Phenomenon or Process",
                                         "Idea or Concept",
                                         "Immunologic Factor",
                                         "Indicator, Reagent, or Diagnostic Aid",
                                         "Individual Behavior",
                                         "Injury or Poisoning",
                                         "Inorganic Chemical",
                                         "Intellectual Product",
                                         "Laboratory or Test Result",
                                         "Laboratory Procedure",
                                         "Language",
                                         "Machine Activity",
                                         "Mammal",
                                         "Manufactured Object",
                                         "Medical Device",
                                         "Mental or Behavioral Dysfunction",
                                         "Mental Process",
                                         "Molecular Biology Research Technique",
                                         "Molecular Function",
                                         "Molecular Sequence",
                                         "Natural Phenomenon or Process",
                                         "Neoplastic Process",
                                         "Nucleic Acid, Nucleoside, or Nucleotide",
                                         "Nucleotide Sequence",
                                         "Occupation or Discipline",
                                         "Occupational Activity",
                                         "Organ or Tissue Function",
                                         "Organic Chemical",
                                         "Organism",
                                         "Organism Attribute",
                                         "Organism Function",
                                         "Organization",
                                         "Pathologic Function",
                                         "Patient or Disabled Group",
                                         "Pharmacologic Substance",
                                         "Phenomenon or Process",
                                         "Physical Object",
                                         "Physiologic Function",
                                         "Plant",
                                         "Population Group",
                                         "Professional or Occupational Group",
                                         "Professional Society",
                                         "Qualitative Concept",
                                         "Quantitative Concept",
                                         "Receptor",
                                         "Regulation or Law",
                                         "Reptile",
                                         "Research Activity",
                                         "Research Device",
                                         "Self-help or Relief Organization",
                                         "Sign or Symptom",
                                         "Social Behavior",
                                         "Spatial Concept",
                                         "Substance",
                                         "Temporal Concept",
                                         "Therapeutic or Preventive Procedure",
                                         "Tissue",
                                         "Vertebrate",
                                         "Virus",
                                         "Vitamin"),
                      return_scispacy_embeddings = FALSE,
                      verbose = TRUE) {

  if (is.null(clinspacy_env$nlp)) {
    clinspacy_init()
  }

  if (clinspacy_env$use_linker) {
    assertthat::assert_that(threshold >= 0.70 & threshold <= 0.99)
  }

  parsed_text = clinspacy_env$nlp(text)
  entity_nums = length(parsed_text$ents)

  if (clinspacy_env$use_linker) {
    return_df = data.frame(cui = character(0),
                           entity = character(0),
                           lemma = character(0),
                           negated = logical(0),
                           semantic_type = character(0),
                           definition = character(0),
                           stringsAsFactors = FALSE)
  } else {
    return_df = data.frame(entity = character(0),
                           lemma = character(0),
                           negated = logical(0),
                           stringsAsFactors = FALSE)
  }

  if (return_scispacy_embeddings == TRUE) {
    for(emb in paste0('emb_', sprintf('%03d', 1:200))) {
      return_df[[emb]] = numeric(0)
    }
  }


  return_df_list = list()

  if (verbose) {
    message(paste('Processing...', text))
    pb = txtProgressBar(min = 0, max = entity_nums, style = 3)
  }

  for (entity_num in seq_len(entity_nums)) {

    if (clinspacy_env$use_linker) {
      if (is.null(unlist(parsed_text$ents[[entity_num]]$`_`$kb_ents))) next
    } else {
      if (!parsed_text$ents[[entity_num]]$has_vector) next
    }


    if (clinspacy_env$use_linker) {
      temp_cuis = parsed_text$ents[[entity_num]]$`_`$kb_ents
      temp_cuis = unlist(temp_cuis)
      temp_df = data.frame(cui = temp_cuis[seq(1, length(temp_cuis), by = 2)],
                           confidence = temp_cuis[seq(2, length(temp_cuis), by = 2)],
                           stringsAsFactors = FALSE)
      temp_df$entity = parsed_text$ents[[entity_num]]$text
    } else {
      temp_df = data.frame(entity = parsed_text$ents[[entity_num]]$text,
                           stringsAsFactors = FALSE)
    }

    temp_df$lemma = parsed_text$ents[[entity_num]]$lemma_

    if (clinspacy_env$use_linker) {
      temp_df = merge(temp_df, cui2vec_definitions, all.x = TRUE) # adds semantic_type and definition
    }

    temp_df$negated = parsed_text$ents[[entity_num]]$`_`$negex

    if (clinspacy_env$use_linker) {
      temp_df = temp_df[temp_df$confidence > threshold, ]
      temp_df$confidence = NULL
      temp_df = temp_df[temp_df$semantic_type %in% semantic_types, ]
    }

    if (return_scispacy_embeddings) {
      temp_df = cbind(temp_df, matrix(parsed_text$ents[[entity_num]]$vector, nrow = 1))
      names(temp_df)[(ncol(temp_df)-200+1):ncol(temp_df)] = paste0('emb_', sprintf('%03d', 1:200))
    }

    return_df_list[[entity_num]] = temp_df

      if (verbose) {
      setTxtProgressBar(pb, entity_num)
    }
  }

  if (verbose) {
    close(pb)
  }

  if (length(return_df_list) > 0) {
    return_df = rbindlist(return_df_list, use.names = TRUE, fill = TRUE)
    setDF(return_df)
    return(return_df)
  } else {
    return(return_df)
  }
}


#' This function binds columns containing concept unique identifiers with which scispacy has
#' 99 percent confidence of being present with values containing frequencies. Negated concepts,
#' as identified by negspacy's NegEx implementation, are ignored and do not count towards
#' the frequencies.
#'
#' @param df A data frame.
#' @param text A character string containing the name of the column to process.
#' @param ... Arguments passed down to \code{\link{clinspacy}}
#' @return A data frame containing the original data frame as well as additional column names
#' for each UMLS concept unique identifer found with values containing frequencies.
#'
#' @examples
#' data(mtsamples)
#' mtsamples_with_cuis = bind_clinspacy(mtsamples[1:5,], text = 'description')
#' str(mtsamples_with_cuis)
bind_clinspacy <- function(df, text, ...) {
  clinspacy_text = text
  assertthat::assert_that(assertthat::has_name(df, text))
  assertthat::assert_that(nrow(df) > 0)
  df_nrow = nrow(df)

  dt = data.table(df)[, .(clinspacy_id = 1:.N, text = get(clinspacy_text))]

  if (clinspacy_env$use_linker) {
    dt = dt[,clinspacy(.SD[,text], ...), clinspacy_id][negated == FALSE, .(clinspacy_id, cui, present = 1)]
    dt = dcast(dt, clinspacy_id ~ cui, value.var = 'present', fun.aggregate = sum)
  } else {
    dt = dt[,clinspacy(.SD[,text], ...), clinspacy_id][negated == FALSE, .(clinspacy_id, entity, present = 1)]
    dt = dcast(dt, clinspacy_id ~ entity, value.var = 'present', fun.aggregate = sum)
  }

  dt2 = data.table(clinspacy_id = 1:df_nrow)
  dt = merge(dt, dt2, all.y=TRUE)
  setnafill(dt, fill = 0, cols = 2:ncol(dt))
  dt[, clinspacy_id := NULL]
  cbind(df, as.data.frame(dt))
}

#' This function binds columns containing concept embeddings for concepts with which scispacy has
#' 99 percent confidence of being present with values containing frequencies. Negated concepts,
#' as identified by negspacy's NegEx implementation, are ignored and do not count towards
#' the embeddings. The concept embeddings are derived from the cui2vec_embeddings dataset
#' included with this package.
#'
#' The embeddings are derived from Andrew Beam's
#' \href{https://github.com/beamandrew/cui2vec}{cui2vec R package}.
#'
#' Citation
#'
#' Beam, A.L., Kompa, B., Schmaltz, A., Fried, I., Griffin, W, Palmer, N.P., Shi, X.,
#' Cai, T., and Kohane, I.S.,, 2019. Clinical Concept Embeddings Learned from Massive
#' Sources of Multimodal Medical Data. arXiv preprint arXiv:1804.01486.
#'
#' License
#'
#' This data is made available under a
#' \href{https://creativecommons.org/licenses/by/4.0/}{CC BY 4.0 license}. The only change
#' made to the original dataset is the renaming of columns.
#'
#' @param df A data frame.
#' @param text A character string containing the name of the column to process.
#' @param type The type of embeddings to return. One of \code{cui2vec} and \code{scispacy}.
#' Whereas \code{cui2vec} embeddings require the UMLS linker to be enabled, the
#' \code{scispacy} embeddings do not. Defaults to \code{scispacy}.
#' @param num_embeddings The number of embeddings to return. This must be a number 1 through
#' 200 for \code{scispacy} embeddings and 1 through 500 for \code{cui2vec} embeddings. Defaults
#' to 200.
#' @param ... Arguments passed down to \code{\link{clinspacy}}
#' @return A data frame containing the original data frame as well as additional column names
#' for each UMLS concept unique identifer found with values containing frequencies.
#'
#' @examples
#' data(mtsamples)
#' mtsamples_with_cuis = bind_clinspacy(mtsamples[1:5,], text = 'description')
#' str(mtsamples_with_cuis)
bind_clinspacy_embeddings <- function(df, text,
                                      type = 'scispacy',
                                      num_embeddings = 200, ...) {
  assertthat::assert_that(type %in% c('cui2vec', 'scispacy'))
  if (type == 'cui2vec') {
    if (!is.null(clinspacy_env$use_linker)) {
      if(clinspacy_env$use_linker == FALSE) {
        stop('You must initiate clinspacy with use_linker = TRUE to use cui2vec embeddings.')
      }
    }
    assertthat::assert_that(num_embeddings >= 1 & num_embeddings <= 500)
  } else if (type == 'scispacy') {
    assertthat::assert_that(num_embeddings >= 1 & num_embeddings <= 200)
  }

  assertthat::assert_that(assertthat::has_name(df, text))
  assertthat::assert_that(nrow(df) > 0)

  clinspacy_text = text
  df_nrow = nrow(df)
  dt = data.table(df)[, .(clinspacy_id = 1:.N, text = get(clinspacy_text))]

  if (type == 'cui2vec') {
    dt = dt[, clinspacy(.SD[,text], return_scispacy_embeddings = FALSE, ...), clinspacy_id]
    dt = dt[negated == FALSE]
    dt[, n := .N, by = .(clinspacy_id, cui)]

    # inner join on cui for only those number of embeddings that are needed
    dt = merge(dt, cui2vec_embeddings[, 1:(num_embeddings + 1)])
    dt = dt[, .(clinspacy_id, cui, n, n*.SD),
            .SDcols = paste0('emb_', sprintf('%03d', 1:num_embeddings))]
    dt[, n := sum(n), by = clinspacy_id]
    dt = dt[, lapply(.SD, function (x) sum(x)/n), by = clinspacy_id,
            .SDcols = paste0('emb_',sprintf('%03d', 1:num_embeddings))]
    dt = unique(dt)
    dt2 = data.table(clinspacy_id = 1:df_nrow)
    dt = merge(dt, dt2, all.y=TRUE)
    dt[, clinspacy_id := NULL]
    return(cbind(df, as.data.frame(dt)))
  } else if (type == 'scispacy') {
    dt = dt[, clinspacy(.SD[,text], return_scispacy_embeddings = TRUE, ...), by = clinspacy_id]
    dt = dt[negated == FALSE]
    dt = dt[, .(clinspacy_id, entity, .SD),
            .SDcols = paste0('emb_', sprintf('%03d', 1:num_embeddings))]
    names(dt)[(ncol(dt)-num_embeddings+1):ncol(dt)] = paste0('emb_', sprintf('%03d', 1:num_embeddings))
    dt = dt[, lapply(.SD, function (x) mean(x, na.rm=TRUE)), by = clinspacy_id,
                     .SDcols = paste0('emb_',sprintf('%03d', 1:num_embeddings))]
    dt2 = data.table(clinspacy_id = 1:df_nrow)
    dt = merge(dt, dt2, all.y=TRUE)
    dt[, clinspacy_id := NULL]
    return(cbind(df, as.data.frame(dt)))
  }
}
