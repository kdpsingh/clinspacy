#' Cui2vec concept embeddings
#'
#' This dataset contains Unified Medical Langauge System (UMLS) concept
#' embeddings from Andrew Beam's
#' \href{https://github.com/beamandrew/cui2vec}{cui2vec R package}. There are
#' 500 embeddings included for each concept.
#'
#' This dataset is not viewable until it has been downloaded, which will occur
#' the very first time you run \code{clinspacy_init()} after installing this
#' package.
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
#' This data is made available under a
#' \href{https://creativecommons.org/licenses/by/4.0/}{CC BY 4.0 license}. The
#' only change made to the original dataset is the renaming of columns.
#'
#' @format A data frame with 109053 rows and 501 variables: \describe{
#'   \item{cui}{A Unified Medical Language System (UMLS) Concept Unique
#'   Identifier (CUI)} \item{emb_001}{Concept embedding vector #1}
#'   \item{emb_002}{Concept embedding vector #2} \item{...}{and so on...}
#'   \item{emb_500}{Concept embedding vector #500} }
#' @source \url{https://figshare.com/s/00d69861786cd0156d81}
#' @return Returns the cui2vec UMLS embeddings as a data frame.
#' @export
dataset_cui2vec_embeddings <- function() {
  source_file = 'https://github.com/ML4LHS/clinspacy/releases/download/v0.1.0/cui2vec_embeddings.rds'
  destination_file = file.path(rappdirs::user_data_dir('clinspacy'), 'cui2vec_embeddings.rds')

  if (!file.exists(destination_file)) {
    if (!dir.exists(rappdirs::user_data_dir('clinspacy'))) {
      dir.create(rappdirs::user_data_dir('clinspacy'), recursive = TRUE)
    }

    message('Downloading the cui2vec_embeddings dataset...')
    utils::download.file(source_file, destination_file)
  }

  readRDS(destination_file)
}

#' Cui2vec concept definitions
#'
#' This dataset contains definitions for the Unified Medical Language System
#' (UMLS) Concept Unique Identifiers (CUIs). These come from Andrew Beam's
#' \href{https://github.com/beamandrew/cui2vec}{cui2vec R package}.
#'
#' License
#'
#' This data is made available under a
#' \href{https://github.com/beamandrew/cui2vec/blob/master/LICENSE.md}{MIT
#' license}. The data is copyrighted in 2019 by Benjamin Kompa, Andrew Beam, and
#' Allen Schmaltz. The only change made to the original dataset is the renaming
#' of columns.
#'
#' @format A data frame with 3053795 rows and 3 variables: \describe{
#'   \item{cui}{A Unified Medical Language System (UMLS) Concept Unique
#'   Identifier (CUI)} \item{semantic_type}{Semantic type of the CUI}
#'   \item{definition}{Definition of the CUI} }
#' @source \url{https://github.com/beamandrew/cui2vec}
#' @return Returns the cui2vec UMLS definitions as a data frame.
#' @export
dataset_cui2vec_definitions <- function() {
  source_file = 'https://github.com/ML4LHS/clinspacy/releases/download/v0.1.0/cui2vec_definitions.rds'
  destination_file = file.path(rappdirs::user_data_dir('clinspacy'), 'cui2vec_definitions.rds')

  if (!file.exists(destination_file)) {
    if (!dir.exists(rappdirs::user_data_dir('clinspacy'))) {
      dir.create(rappdirs::user_data_dir('clinspacy'), recursive = TRUE)
    }

    message('Downloading the cui2vec_definitions dataset...')
    utils::download.file(source_file, destination_file)
  }

  readRDS(destination_file)
}
