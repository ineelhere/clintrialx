#' Print a Welcome Message
#'
#' This function prints a welcome message for ClinTrialX.
#'
#' @return A character string containing the welcome message.
#' @export
#' @examples
#' hello()
hello <- function() {
  message <- "👋 Welcome to ClinTrialX!"
  Encoding(message) <- "UTF-8"
  print(message)
}
