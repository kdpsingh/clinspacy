#' Medical transcription samples.
#'
#' This dataset contains sample medical transcriptions for various medical specialties.
#'
#' Acknowledgements
#'
#' This data was scraped from \href{https://mtsamples.com}{https://mtsamples.com} by Tara Boyle.
#'
#' License
#' This data is made available under a
#' \href{https://creativecommons.org/share-your-work/public-domain/cc0/}{CC0: Public Domain license}.
#'
#' @format A data frame with 4999 rows and 6 variables:
#' \describe{
#'   \item{note_id}{A unique identifier for each note}
#'   \item{description}{A description or chief concern}
#'   \item{medical_specialty}{Medical specialty of the note}
#'   \item{sample_name}{mtsamples.com note name}
#'   \item{transcription}{Transcription of note text}
#'   \item{keywords}{Keywords}
#' }
#' @source \url{https://www.kaggle.com/tboyle10/medicaltranscriptions/data}
'mtsamples'
