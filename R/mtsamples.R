#' Medical transcription samples.
#'
#' This dataset contains sample medical transcriptions for various medical
#' specialties.
#'
#' Acknowledgements
#'
#' This data was scraped from
#' \href{https://mtsamples.com}{https://mtsamples.com} by Tara Boyle.
#'
#' License This data is made available under a
#' \href{https://creativecommons.org/share-your-work/public-domain/cc0/}{CC0:
#' Public Domain license}.
#'
#' @format A data frame with 4999 rows and 6 variables: \describe{
#'   \item{note_id}{A unique identifier for each note} \item{description}{A
#'   description or chief concern} \item{medical_specialty}{Medical specialty of
#'   the note} \item{sample_name}{mtsamples.com note name}
#'   \item{transcription}{Transcription of note text} \item{keywords}{Keywords}
#'   }
#' @source \url{https://www.kaggle.com/tboyle10/medicaltranscriptions/data}
#' @export
dataset_mtsamples <- function() {
  source_file = 'https://github.com/ML4LHS/clinspacy/releases/download/v0.1.0/mtsamples.rds'
  destination_file = file.path(rappdirs::user_data_dir('clinspacy'), 'mtsamples.rds')

  if (!file.exists(destination_file)) {
    if (!dir.exists(rappdirs::user_data_dir('clinspacy'))) {
      dir.create(rappdirs::user_data_dir('clinspacy'), recursive = TRUE)
    }

    message('Downloading the mtsamples dataset...')
    utils::download.file(source_file, destination_file)
  }

  readRDS(destination_file)
}
