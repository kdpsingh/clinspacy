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


#' Initializes clinspacy. This function is optional to run but gives you more
#' control over the parameters used by scispacy at initiation. If you do not run
#' this function, it will be run with default parameters the first time that any
#' of the package functions are run.
#'
#' @param miniconda Defaults to TRUE, which results in miniconda being installed
#'   (~400 MB) and configured with the "clinspacy" conda environment. If you
#'   want to override this behavior, set \code{miniconda} to \code{FALSE} and
#'   specify an alternative environment using use_python() or use_conda().
#' @param use_linker Defaults to \code{FALSE}. To turn on the UMLS linker, set
#'   this to \code{TRUE}.
#' @param linker_threshold Defaults to 0.99. This arguemtn is only relevant if
#'   \code{use_linker} is set to \code{TRUE}. It refers to the confidence
#'   threshold value used by the scispacy UMLS entity linker. Note: This can be
#'   lower than the \code{threshold} from \code{\link{clinspacy_init}}). The
#'   linker_threshold can only be set once per session.
#' @param ... Additional settings available from:
#'   \href{https://github.com/allenai/scispacy}{https://github.com/allenai/scispacy}.
#'
#' @return No return value.
#'
#' @export
clinspacy_init <- function(miniconda = TRUE, use_linker = FALSE, linker_threshold = 0.99, ...) {

  assertthat::assert_that(assertthat::is.flag(miniconda))
  assertthat::assert_that(assertthat::is.flag(use_linker))

  if (use_linker) {
    assertthat::assert_that(linker_threshold >= 0.70 & linker_threshold <= 0.99)
  }

  # If clinspacy has already been initialized without a linker and you now want to add a linker
  if (!is.null(clinspacy_env$nlp)) {
    if (clinspacy_env$use_linker == FALSE & use_linker == TRUE) {
      if(is.null(clinspacy_env$linker)) {
        message('Loading the UMLS entity linker... (this may take a while)')
        clinspacy_env$linker <- clinspacy_env$scispacy$linking$EntityLinker(resolve_abbreviations=TRUE,
                                                                            name="umls",
                                                                            threshold = linker_threshold, ...)
      }
      clinspacy_env$use_linker <- use_linker
      message('Adding the UMLS entity linker to the spaCy pipeline...')
      clinspacy_env$nlp$add_pipe(clinspacy_env$linker)
      return(invisible())
    } else if (clinspacy_env$use_linker == TRUE & use_linker == FALSE) {
      clinspacy_env$use_linker <- use_linker
      message('Removing the UMLS entity linker from the spaCy pipeline...')
      clinspacy_env$nlp$remove_pipe('EntityLinker')
      return(invisible())
    } else {
      message('Clinspacy has already been initialized. Set the use_linker argument to turn the linker on or off.')
      return(invisible())
    }
  }

  # If clinspacy has not been initialized previously

  message('Initializing clinspacy using clinspacy_init()...')

  clinspacy_env$use_linker <- use_linker

  if (miniconda) {
    message('Checking if miniconda is installed...')
    tryCatch(reticulate::install_miniconda(),
             error = function (e) {return()})

    # By now, miniconda should be installed. Let's check if the clinspacy environment is configured
    is_clinspacy_env_installed = tryCatch(reticulate::use_miniconda(condaenv = 'clinspacy', required = TRUE),
                                          error = function (e) {'not installed'})

    if (!is.null(is_clinspacy_env_installed)) { # this means the 'clinspacy' condaenv *is not* installed
      message('Clinspacy requires the clinspacy conda environment. Attempting to create...')
      reticulate::conda_create(envname = 'clinspacy', python_version = '3.8')
    }

    # This is intentional -- will throw an error if environment creation failed
    reticulate::use_miniconda(condaenv = 'clinspacy', required = TRUE)
  }

  if (!reticulate::py_module_available('spacy')) {
    message('SpaCy not found. Installing spaCy...')
    # Do NOT install using pip because no binary available and build fails on Windows
    reticulate::py_install('spacy==2.3.0', envname = 'clinspacy')
  }

  if (!reticulate::py_module_available('scispacy')) {
    message('ScispaCy not found. Installing scispaCy...')
    reticulate::py_install('scispacy==0.2.5', envname = 'clinspacy', pip = TRUE)
  }

  if (!reticulate::py_module_available('en_core_sci_lg')) {
    message('en_core_sci_lg language model not found. Installing en_core_sci_lg...')
    reticulate::py_install('https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.2.5/en_core_sci_lg-0.2.5.tar.gz', envname = 'clinspacy', pip = TRUE)
  }

  if (!reticulate::py_module_available('medspacy')) {
    message('MedspaCy not found. Installing medspaCy...')
    reticulate::py_install('medspacy==0.1.0.2', envname = 'clinspacy', pip = TRUE)
  }

  message('Importing spaCy...')
  clinspacy_env$spacy <- reticulate::import('spacy', delay_load = TRUE)
  message('Importing scispaCy...')
  clinspacy_env$scispacy <-  reticulate::import('scispacy', delay_load = TRUE)
  message('Importing medspaCy...')
  clinspacy_env$medspacy <-  reticulate::import('medspacy', delay_load = TRUE)

  message('Loading the en_core_sci_lg language model...')
  clinspacy_env$nlp <- clinspacy_env$spacy$load("en_core_sci_lg")
  # message('Loading NegEx...')
  # clinspacy_env$negex <- clinspacy_env$negspacy$negation$Negex(clinspacy_env$nlp)

  if (use_linker) {
    message('Loading the UMLS entity linker... (this may take a while)')
    clinspacy_env$linker <- clinspacy_env$scispacy$linking$EntityLinker(resolve_abbreviations=TRUE,
                                                                        name="umls",
                                                                        threshold = linker_threshold, ...)
    message('Adding the UMLS entity linker to the spacy pipeline...')
    clinspacy_env$nlp$add_pipe(clinspacy_env$linker)
  }

  clinspacy_env$context <- clinspacy_env$medspacy$context$ConTextComponent(clinspacy_env$nlp)
  clinspacy_env$nlp$add_pipe(clinspacy_env$context)

  clinspacy_env$sectionizer <- clinspacy_env$medspacy$section_detection$Sectionizer(clinspacy_env$nlp)
  clinspacy_env$nlp$add_pipe(clinspacy_env$sectionizer)
  invisible()
}

#' Performs biomedical named entity recognition, Unified Medical Language System
#' (UMLS) concept mapping, and negation detection using the Python spaCy,
#' scispacy, and negspacy packages. This function identifies only those concept
#' unique identifiers with with scispacy has 99 percent confidence of being
#' present. Negation is identified using negspacy's NegEx implementation.
#'
#' @param text A character string of length 1 containing medical text that you
#'   would like to process.
#' @param threshold Defaults to 0.99. The confidence threshold value used by
#'   clinspacy (can be higher than the \code{linker_threshold} from
#'   \code{\link{clinspacy_init}}). Note that whereas the linker_threshold can
#'   only be set once per session, this threshold can be updated during the R
#'   session.
#' @param semantic_types Character vector containing any combination of the
#'   following: c(NA, "Acquired Abnormality", "Activity", "Age Group", "Amino
#'   Acid Sequence", "Amino Acid, Peptide, or Protein", "Amphibian", "Anatomical
#'   Abnormality", "Anatomical Structure", "Animal", "Antibiotic", "Archaeon",
#'   "Bacterium", "Behavior", "Biologic Function", "Biologically Active
#'   Substance", "Biomedical Occupation or Discipline", "Biomedical or Dental
#'   Material", "Bird", "Body Location or Region", "Body Part, Organ, or Organ
#'   Component", "Body Space or Junction", "Body Substance", "Body System",
#'   "Carbohydrate Sequence", "Cell", "Cell Component", "Cell Function", "Cell
#'   or Molecular Dysfunction", "Chemical", "Chemical Viewed Functionally",
#'   "Chemical Viewed Structurally", "Classification", "Clinical Attribute",
#'   "Clinical Drug", "Conceptual Entity", "Congenital Abnormality", "Daily or
#'   Recreational Activity", "Diagnostic Procedure", "Disease or Syndrome",
#'   "Drug Delivery Device", "Educational Activity", "Element, Ion, or Isotope",
#'   "Embryonic Structure", "Entity", "Environmental Effect of Humans",
#'   "Enzyme", "Eukaryote", "Event", "Experimental Model of Disease", "Family
#'   Group", "Finding", "Fish", "Food", "Fully Formed Anatomical Structure",
#'   "Functional Concept", "Fungus", "Gene or Genome", "Genetic Function",
#'   "Geographic Area", "Governmental or Regulatory Activity", "Group", "Group
#'   Attribute", "Hazardous or Poisonous Substance", "Health Care Activity",
#'   "Health Care Related Organization", "Hormone", "Human", "Human-caused
#'   Phenomenon or Process", "Idea or Concept", "Immunologic Factor",
#'   "Indicator, Reagent, or Diagnostic Aid", "Individual Behavior", "Injury or
#'   Poisoning", "Inorganic Chemical", "Intellectual Product", "Laboratory or
#'   Test Result", "Laboratory Procedure", "Language", "Machine Activity",
#'   "Mammal", "Manufactured Object", "Medical Device", "Mental or Behavioral
#'   Dysfunction", "Mental Process", "Molecular Biology Research Technique",
#'   "Molecular Function", "Molecular Sequence", "Natural Phenomenon or
#'   Process", "Neoplastic Process", "Nucleic Acid, Nucleoside, or Nucleotide",
#'   "Nucleotide Sequence", "Occupation or Discipline", "Occupational Activity",
#'   "Organ or Tissue Function", "Organic Chemical", "Organism", "Organism
#'   Attribute", "Organism Function", "Organization", "Pathologic Function",
#'   "Patient or Disabled Group", "Pharmacologic Substance", "Phenomenon or
#'   Process", "Physical Object", "Physiologic Function", "Plant", "Population
#'   Group", "Professional or Occupational Group", "Professional Society",
#'   "Qualitative Concept", "Quantitative Concept", "Receptor", "Regulation or
#'   Law", "Reptile", "Research Activity", "Research Device", "Self-help or
#'   Relief Organization", "Sign or Symptom", "Social Behavior", "Spatial
#'   Concept", "Substance", "Temporal Concept", "Therapeutic or Preventive
#'   Procedure", "Tissue", "Vertebrate", "Virus", "Vitamin")
#' @param return_scispacy_embeddings Defaults to \code{FALSE}. This is primarily
#'   intended for use by the \code{\link{bind_clinspacy_embeddings}} function to
#'   obtain scispacy embeddings.
#' @param verbose Defaults to TRUE.
#' @return A data frame containing the UMLS concept unique identifiers (cui),
#'   entities, lemmatized entities, CyContext negation status (\code{TRUE} means
#'   negated, \code{FALSE} means *not* negated), other CyContext contexts, and
#'   section title from the Sectionizer.
#'
#' @examples
#' \dontrun{
#' clinspacy_single('This patient has diabetes and CKD stage 3 but no HTN.')
#' }
#'
#' @noRd
clinspacy_single <- function(text, threshold = 0.99,
                      semantic_types = c(NA,
                                         "Acquired Abnormality",
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
                           semantic_type = character(0),
                           definition = character(0),
                           is_family = logical(0),
                           is_historical = logical(0),
                           is_hypothetical = logical(0),
                           is_negated = logical(0),
                           is_uncertain = logical(0),
                           section_category = character(0),
                           stringsAsFactors = FALSE)
  } else {
    return_df = data.frame(entity = character(0),
                           lemma = character(0),
                           is_family = logical(0),
                           is_historical = logical(0),
                           is_hypothetical = logical(0),
                           is_negated = logical(0),
                           is_uncertain = logical(0),
                           section_category = character(0),
                           stringsAsFactors = FALSE)
  }

  if (return_scispacy_embeddings == TRUE) {
    for(emb in paste0('emb_', sprintf('%03d', 1:200))) {
      return_df[[emb]] = numeric(0)
    }
  }


  return_df_list =
    lapply(seq_len(entity_nums),
           function (entity_num) {

             if (clinspacy_env$use_linker) {
               if (is.null(unlist(parsed_text$ents[[entity_num]]$`_`$kb_ents)))
                 return(return_df)
             } else {
               if (!parsed_text$ents[[entity_num]]$has_vector)
                 return(return_df)
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
               if (is.null(clinspacy_env$cui2vec_definitions)) {
                 clinspacy_env$cui2vec_definitions <- dataset_cui2vec_definitions()
               }
               temp_df = merge(temp_df, clinspacy_env$cui2vec_definitions, all.x = TRUE) # adds semantic_type and definition
             }

             temp_df$is_family = parsed_text$ents[[entity_num]]$`_`$is_family
             temp_df$is_historical = parsed_text$ents[[entity_num]]$`_`$is_historical
             temp_df$is_hypothetical = parsed_text$ents[[entity_num]]$`_`$is_hypothetical
             temp_df$is_negated = parsed_text$ents[[entity_num]]$`_`$is_negated
             temp_df$is_uncertain = parsed_text$ents[[entity_num]]$`_`$is_uncertain
             temp_df$section_category =
               ifelse(!is.null(parsed_text$ents[[entity_num]]$`_`$section_category),
                      parsed_text$ents[[entity_num]]$`_`$section_category,
                      NA_character_)

             if (clinspacy_env$use_linker) {
               temp_df = temp_df[temp_df$confidence > threshold, ]
               temp_df$confidence = NULL
               temp_df = temp_df[temp_df$semantic_type %in% semantic_types, ]
             }

             if (return_scispacy_embeddings) {
               if (nrow(temp_df) > 0) {
                 temp_df = cbind(temp_df, matrix(parsed_text$ents[[entity_num]]$vector, nrow = 1))
                 names(temp_df)[(ncol(temp_df)-200+1):ncol(temp_df)] = paste0('emb_', sprintf('%03d', 1:200))
               } else {
                 temp_df = return_df
               }
             }

             temp_df
           })

  if (length(return_df_list) > 0) {
    return_df = rbindlist(return_df_list, use.names = TRUE, fill = TRUE)
    setDF(return_df)
    return(return_df)
  } else {
    return(return_df)
  }
}

#' This is the primary function for processing both data frames and character
#' vectors in the \code{clinspacy} package.
#'
#' @param x Either a data.frame or a character vector
#' @param df_col If \code{x} is a data.frame then you must specify the name of
#'   the column containing text as a string.
#' @param df_id If \code{x} is a data.frame then you may *optionally* specify an
#'   \code{id} column to help match up each row of text in the original data
#'   frame with the resulting output. If you do not specify an id, the resulting
#'   will contain the row number from the original data.frame.
#' @param threshold Defaults to 0.99. The confidence threshold value used by
#'   clinspacy (can be higher than the \code{linker_threshold} from
#'   \code{\link{clinspacy_init}}). Note that whereas the linker_threshold can
#'   only be set once per session, this threshold can be updated during the R
#'   session.
#' @param semantic_types Character vector containing any combination of the
#'   following: c(NA, "Acquired Abnormality", "Activity", "Age Group", "Amino
#'   Acid Sequence", "Amino Acid, Peptide, or Protein", "Amphibian", "Anatomical
#'   Abnormality", "Anatomical Structure", "Animal", "Antibiotic", "Archaeon",
#'   "Bacterium", "Behavior", "Biologic Function", "Biologically Active
#'   Substance", "Biomedical Occupation or Discipline", "Biomedical or Dental
#'   Material", "Bird", "Body Location or Region", "Body Part, Organ, or Organ
#'   Component", "Body Space or Junction", "Body Substance", "Body System",
#'   "Carbohydrate Sequence", "Cell", "Cell Component", "Cell Function", "Cell
#'   or Molecular Dysfunction", "Chemical", "Chemical Viewed Functionally",
#'   "Chemical Viewed Structurally", "Classification", "Clinical Attribute",
#'   "Clinical Drug", "Conceptual Entity", "Congenital Abnormality", "Daily or
#'   Recreational Activity", "Diagnostic Procedure", "Disease or Syndrome",
#'   "Drug Delivery Device", "Educational Activity", "Element, Ion, or Isotope",
#'   "Embryonic Structure", "Entity", "Environmental Effect of Humans",
#'   "Enzyme", "Eukaryote", "Event", "Experimental Model of Disease", "Family
#'   Group", "Finding", "Fish", "Food", "Fully Formed Anatomical Structure",
#'   "Functional Concept", "Fungus", "Gene or Genome", "Genetic Function",
#'   "Geographic Area", "Governmental or Regulatory Activity", "Group", "Group
#'   Attribute", "Hazardous or Poisonous Substance", "Health Care Activity",
#'   "Health Care Related Organization", "Hormone", "Human", "Human-caused
#'   Phenomenon or Process", "Idea or Concept", "Immunologic Factor",
#'   "Indicator, Reagent, or Diagnostic Aid", "Individual Behavior", "Injury or
#'   Poisoning", "Inorganic Chemical", "Intellectual Product", "Laboratory or
#'   Test Result", "Laboratory Procedure", "Language", "Machine Activity",
#'   "Mammal", "Manufactured Object", "Medical Device", "Mental or Behavioral
#'   Dysfunction", "Mental Process", "Molecular Biology Research Technique",
#'   "Molecular Function", "Molecular Sequence", "Natural Phenomenon or
#'   Process", "Neoplastic Process", "Nucleic Acid, Nucleoside, or Nucleotide",
#'   "Nucleotide Sequence", "Occupation or Discipline", "Occupational Activity",
#'   "Organ or Tissue Function", "Organic Chemical", "Organism", "Organism
#'   Attribute", "Organism Function", "Organization", "Pathologic Function",
#'   "Patient or Disabled Group", "Pharmacologic Substance", "Phenomenon or
#'   Process", "Physical Object", "Physiologic Function", "Plant", "Population
#'   Group", "Professional or Occupational Group", "Professional Society",
#'   "Qualitative Concept", "Quantitative Concept", "Receptor", "Regulation or
#'   Law", "Reptile", "Research Activity", "Research Device", "Self-help or
#'   Relief Organization", "Sign or Symptom", "Social Behavior", "Spatial
#'   Concept", "Substance", "Temporal Concept", "Therapeutic or Preventive
#'   Procedure", "Tissue", "Vertebrate", "Virus", "Vitamin")
#' @param return_scispacy_embeddings Defaults to \code{FALSE}. This is primarily
#'   intended for use by the \code{\link{bind_clinspacy_embeddings}} function to
#'   obtain scispacy embeddings. In order for scispacy embeddings to be
#'   available to \code{\link{bind_clinspacy_embeddings}}, you must set this to
#'   \code{TRUE}.
#' @param verbose Defaults to \code{TRUE}.
#' @param output_file Defaults to \code{NULL}. This is an optional argument that
#'   writes the output to a comma-separated value (CSV) file.
#' @param overwrite Defaults to \code{FALSE}. If \code{output_file} already
#'   exists and \code{overwrite} is set to \code{FALSE}, then you will be
#'   prompted to confirm whether you would like to overwrite the file. If set to
#'   \code{TRUE}, then \code{output_file} will automatically be overwritten.
#'
#' @return If \code{output_file} is \code{NULL} (the default), then this
#'   function returns a data frame containing the UMLS concept unique
#'   identifiers (cui), entities, lemmatized entities, CyContext negation status
#'   (\code{TRUE} means negated, \code{FALSE} means *not* negated), other
#'   CyContext contexts, and section title from the clinical sectionizer. If
#'   \code{output_file} points to a file name, then the name of the created file
#'   will be returned.
#'
#' @examples
#' \dontrun{
#' clinspacy('This patient has diabetes and CKD stage 3 but no HTN.')
#'
#' clinspacy(c('This pt has CKD and HTN', 'Pt only has CKD but no HTN'))
#'
#' data.frame(text = c('This pt has CKD and HTN', 'Diabetes is present'),
#'            stringsAsFactors = FALSE) %>%
#'   clinspacy(df_col = 'text')
#'
#' if (!dir.exists(rappdirs::user_data_dir('clinspacy'))) {
#'   dir.create(rappdirs::user_data_dir('clinspacy'), recursive = TRUE)
#'   }
#'
#' clinspacy(c('This pt has CKD and HTN', 'Has CKD but no HTN'),
#'   output_file = file.path(rappdirs::user_data_dir('clinspacy'),
#'                           'output.csv'),
#'   overwrite = TRUE)
#' }
#'
#' @export
clinspacy <- function(x,
                      df_col = NULL,
                      df_id = NULL,
                      threshold = 0.99,
                      semantic_types = c(NA,
                                         "Acquired Abnormality",
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
                      verbose = TRUE,
                      output_file = NULL,
                      overwrite = FALSE) {

  text = NULL
  clinspacy_id = NULL

  if (is.null(clinspacy_env$nlp)) {
    clinspacy_init()
  }

  if(is.character(x)) {
    dt = data.table(text = x)[, clinspacy_id := 1:.N][, list(clinspacy_id, text)]
  } else if(is.data.frame(x)) {
    if (!is.null(df_col)) {
      if (!is.null(df_id)) {
        if (length(x[[df_id]]) != length(unique(x[[df_id]]))) {
          stop ('If provided, the id column must be unique to each row.')
        }
        dt = data.table(clinspacy_id = x[[df_id]], text = x[[df_col]])
      } else {
        message(paste0('Since x is a data.frame and no id column was provided, ',
                       'the row number will be used as the id.'))
        dt = data.table(text = x[[df_col]])[, clinspacy_id := 1:.N][, list(clinspacy_id, text)]
      }
    } else {
      stop('If x is a data.frame, you must provide a text column as a string.')
    }
  } else {
    stop('x must be a character vector or a data.frame.')
  }


  if (nrow(dt) == 0) {
    stop('You must provide at least one value in `x` for clinspacy() to process.')
  }

  if (verbose) {
    pb = utils::txtProgressBar(min = 0, max = nrow(dt), style = 3)
  } else {
    pb = NULL
  }

  if (is.null(output_file)) {
    dt = dt[, {
          if (verbose) {
            utils::setTxtProgressBar(pb, .GRP)
          }
          clinspacy_single(.SD[,text],
                               threshold = threshold,
                               semantic_types = semantic_types,
                               return_scispacy_embeddings = return_scispacy_embeddings,
                               verbose = verbose)

            },
            by = clinspacy_id]
    if (verbose) {
      close(pb)
    }
    setDF(dt)
    return(dt)
  } else {
    if (file.exists(output_file) && overwrite == FALSE) {
      repeat {
        check_overwrite = readline(paste0(output_file, ' already exists. ',
                                          'Would you like to overwrite it (y/n)? '))
        if (check_overwrite == 'n') {
          return() # Return because the user would not like to overwrite
        } else if (check_overwrite == 'y') {
          break # Let us go ahead and overwrite
        }
      }
    }
    unlink(output_file)
    dt = dt[, {if (verbose) {
                utils::setTxtProgressBar(pb, .GRP)
              }
              data.table::fwrite(
                data.table(clinspacy_id = clinspacy_id,
                 clinspacy_single(.SD[,text],
                                  threshold = threshold,
                                  semantic_types = semantic_types,
                                  return_scispacy_embeddings = return_scispacy_embeddings,
                                  verbose = verbose)),
      output_file,
      append = TRUE)
      },
      by = clinspacy_id]

    if (verbose) {
      close(pb)
    }

    return(output_file)
  }
}

#' This function binds columns containing either the lemma of the entity or the
#' UMLS concept unique identifier (CUI) with frequencies to a data frame. The
#' resulting data frame can be used to train a machine learning model or for
#' additional feature selection.
#'
#' @param clinspacy_output A data.frame or file name containing the output from
#'   \code{\link{clinspacy}}.
#' @param df The data.frame to which you would like to bind the output of
#'   \code{\link{clinspacy}}.
#' @param cs_col Name of the column in the \code{clinspacy_output} that you
#'   would like to pivot. For example: \code{"entity"}, \code{"lemma"},
#'   \code{"cui"}, or \code{"definition"}. Defaults to \code{"lemma"} if
#'   \code{use_linker} is set to \code{FALSE} and \code{"cui"} if
#'   \code{use_linker} is set to \code{TRUE}.
#' @param df_id The name of the \code{id} column in the data frame with which
#'   the \code{clinspacy_id} column in \code{clinspacy_output} will be joined.
#'   If you supplied a \code{df_id} in \code{\link{clinspacy}}, then you must
#'   also supply it here. If you did not supply it in \code{\link{clinspacy}},
#'   then it will default to the row number (similar behavior to in
#'   \code{\link{clinspacy}}).
#' @param subset Logical criteria represented as a string by which the
#'   \code{clinspacy_output} will be subsetted prior to building the output data
#'   frame. Defaults to \code{"is_negated == FALSE"}, which removes negated
#'   concepts prior to generating the output. Any column in
#'   \code{clinspacy_output} may be referenced here. To avoid any subsetting,
#'   set this to \code{NULL}.
#' @return A data frame containing the original data frame as well as additional
#'   column names for each lemma or UMLS concept unique identifer found with
#'   values containing frequencies.
#'
#' @examples
#' \dontrun{
#' mtsamples <- dataset_mtsamples()
#' mtsamples[1:5,] %>%
#'   clinspacy(df_col = 'description') %>%
#'   bind_clinspacy(mtsamples[1:5,])
#' }
#' @export
bind_clinspacy <- function(clinspacy_output, df,
                           cs_col = NULL, df_id = NULL,
                           subset = 'is_negated == FALSE') {

  clinspacy_id = NULL

  if (is.null(cs_col)) {
    if (clinspacy_env$use_linker == TRUE) {
      cs_col = 'cui'
    } else {
      cs_col = 'lemma'
    }
  }

  # Specify the scispacy embeddings columns to remove them, in case
  # return_scispacy_embeddings was set to TRUE in clinspacy()

  scispacy_embedding_columns = paste0('emb_',sprintf('%03d', 1:200))

  if (is.character(clinspacy_output)) {
    clinspacy_output = suppressWarnings(data.table::fread(clinspacy_output, drop=scispacy_embedding_columns))
  } else if (is.data.frame(clinspacy_output)){
    clinspacy_output = data.table::copy(clinspacy_output)
    setDT(clinspacy_output)
    suppressWarnings(clinspacy_output[, (scispacy_embedding_columns) := NULL])
  } else {
    stop('clinspacy_output must be a character vector or a data.frame.')
  }

  setDT(df)

  assertthat::assert_that(assertthat::has_name(clinspacy_output, cs_col))
  assertthat::assert_that(nrow(clinspacy_output) > 0)
  assertthat::assert_that(nrow(df) > 0)

  if (!is.null(subset)) {
    clinspacy_output = clinspacy_output[eval(parse(text = subset))]
  }

  if (is.null(df_id)) {
    df[, clinspacy_id := 1:.N]
    df_id = 'clinspacy_id'
  } else {
    assertthat::assert_that(assertthat::has_name(df, df_id))
  }

  clinspacy_output = dcast(clinspacy_output,
                           paste0('clinspacy_id~', cs_col),
                           value.var = 'clinspacy_id',
                           fun.aggregate = length)


  output = merge(df, clinspacy_output, all.x=TRUE,
                 by.x = df_id, by.y = 'clinspacy_id')

  # Will remove if works okay because new default for id column is clinspacy_id
  # if (df_id == 'clinspacy_id') {
  #   output[, clinspacy_id := NULL]
  # }

  setDF(output)
  return(output)
}

#' This function binds columns containing entity or concept embeddings to a data
#' frame. The entity embeddings are derived from the scispacy package, and the
#' concept embeddings are derived from the
#' \code{\link{dataset_cui2vec_embeddings}} dataset included with this package.
#'
#' The embeddings are derived from Andrew Beam's
#' \href{https://github.com/beamandrew/cui2vec}{cui2vec R package}.
#'
#' Citation
#'
#' Beam, A.L., Kompa, B., Schmaltz, A., Fried, I., Griffin, W, Palmer, N.P.,
#' Shi, X., Cai, T., and Kohane, I.S.,, 2019. Clinical Concept Embeddings
#' Learned from Massive Sources of Multimodal Medical Data. arXiv preprint
#' arXiv:1804.01486.
#'
#' License
#'
#' The cui2vec data is made available under a
#' \href{https://creativecommons.org/licenses/by/4.0/}{CC BY 4.0 license}. The
#' only change made to the original dataset is the renaming of columns.
#'
#' @param clinspacy_output A data.frame or file name containing the output from
#'   \code{\link{clinspacy}}. In order for scispacy embeddings to be available
#'   to \code{\link{bind_clinspacy_embeddings}}, you must set
#'   \code{return_scispacy_embeddings} to \code{TRUE} when running
#'   \code{\link{clinspacy}} so that the embeddings are included within
#'   \code{clinspacy_output}.
#' @param df The data.frame to which you would like to bind the output of
#'   \code{\link{clinspacy}}.
#' @param type The type of embeddings to return. One of \code{scispacy} and
#'   \code{cui2vec}. Whereas \code{cui2vec} embeddings require the UMLS linker
#'   to be enabled, the \code{scispacy} embeddings do not. Defaults to
#'   \code{scispacy}.
#' @param df_id The name of the \code{id} column in the data frame with which
#'   the \code{id} column in \code{clinspacy_output} will be joined. If you
#'   supplied a \code{df_id} in \code{\link{clinspacy}}, then you must also
#'   supply it here. If you did not supply it in \code{\link{clinspacy}}, then
#'   it will default to the row number (similar behavior to in
#'   \code{\link{clinspacy}}).
#' @param subset Logical criteria represented as a string by which the
#'   \code{clinspacy_output} will be subsetted prior to building the output data
#'   frame. Defaults to \code{"is_negated == FALSE"}, which removes negated
#'   concepts prior to generating the output. Any column in
#'   \code{clinspacy_output} may be referenced here. To avoid any subsetting,
#'   set this to \code{NULL}.
#' @return A data frame containing the original data frame as well as the
#'   concept embeddings. For scispacy embeddings, this returns 200 columns of
#'   embeddings. For cui2vec embeddings, this returns 500 columns of embedings.
#'   The resulting data frame can be used to train a machine learning model.
#'
#' @examples
#' \dontrun{
#' mtsamples <- dataset_mtsamples()
#' mtsamples[1:5,] %>%
#'   clinspacy(df_col = 'description', return_scispacy_embeddings = TRUE) %>%
#'   bind_clinspacy_embeddings(mtsamples[1:5,])
#' }
#'
#' @export
bind_clinspacy_embeddings <- function(clinspacy_output, df,
                                      type = 'scispacy',
                                      df_id = NULL,
                                      subset = 'is_negated == FALSE') {

  clinspacy_id = NULL

  assertthat::assert_that(type %in% c('cui2vec', 'scispacy'))

  if (type == 'cui2vec') {
    if (clinspacy_env$use_linker == FALSE) {
      stop(paste0('You must initiate clinspacy with use_linker = TRUE ',
                  'to use cui2vec embeddings.'))
    }

    if (is.null(clinspacy_env$cui2vec_embeddings)) {
      clinspacy_env$cui2vec_embeddings <- dataset_cui2vec_embeddings()
    }
  }

  scispacy_embedding_columns = paste0('emb_',sprintf('%03d', 1:200))
  cui2vec_embedding_columns = paste0('emb_',sprintf('%03d', 1:500))

  if (is.character(clinspacy_output)) {
    if (type != 'scispacy') {
      clinspacy_output = suppressWarnings(data.table::fread(clinspacy_output, drop=scispacy_embedding_columns))
    } else {
      clinspacy_output = suppressWarnings(data.table::fread(clinspacy_output))
    }
  } else if (is.data.frame(clinspacy_output)){
    clinspacy_output = data.table::copy(clinspacy_output)
    setDT(clinspacy_output)
    if (type != 'scispacy') {
      suppressWarnings(clinspacy_output[, (scispacy_embedding_columns) := NULL])
    }
  } else {
    stop('clinspacy_output must be a character vector or a data.frame.')
  }

  if (type == 'scispacy') {
    if (length(intersect(names(clinspacy_output), scispacy_embedding_columns)) != 200) {
      stop(paste0('When running clinspacy(), you need to set ',
                  'return_scispacy_embeddings to TRUE.'))
    }
  }

  setDT(df)

  assertthat::assert_that(nrow(clinspacy_output) > 0)
  assertthat::assert_that(nrow(df) > 0)

  if (!is.null(subset)) {
    clinspacy_output = clinspacy_output[eval(parse(text = subset))]
  }

  if (is.null(df_id)) {
    df[, clinspacy_id := 1:.N]
    df_id = 'clinspacy_id'
  } else {
    assertthat::assert_that(assertthat::has_name(df, df_id))
  }

  if (type == 'scispacy') {
    clinspacy_output = clinspacy_output[, list(clinspacy_id, .SD), .SDcols = scispacy_embedding_columns]
    names(clinspacy_output)[(ncol(clinspacy_output)-200+1):ncol(clinspacy_output)] = scispacy_embedding_columns
    clinspacy_output = clinspacy_output[, lapply(.SD, function (x) mean(x, na.rm=TRUE)), by = clinspacy_id,
            .SDcols = scispacy_embedding_columns]
  } else if (type == 'cui2vec') {
    clinspacy_output = merge(clinspacy_output,
                             clinspacy_env$cui2vec_embeddings, by='cui')
    # clinspacy_output = clinspacy_output[, .(id, n, n*.SD),
    #         .SDcols = cui2vec_embedding_columns]
    # clinspacy_output[, n := sum(n), by = id]
    # clinspacy_output = clinspacy_output[, lapply(.SD, function (x) sum(x)/n), by = clinspacy_id,
    #         .SDcols = paste0('emb_',sprintf('%03d', 1:num_embeddings))]
    clinspacy_output = clinspacy_output[, lapply(.SD, function (x) mean(x, na.rm=TRUE)), by = clinspacy_id,
                                        .SDcols = cui2vec_embedding_columns]
  }

  output = merge(df, clinspacy_output, all.x=TRUE,
                 by.x = df_id, by.y = 'clinspacy_id')

  # if (df_id == 'clinspacy_id') {
  #   output[, clinspacy_id := NULL]
  # }

  setDF(output)
  return(output)
}
