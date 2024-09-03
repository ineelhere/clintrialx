#' Print a Welcome Message
#'
#' This function returns a welcome message for ClinTrialX.
#'
#' @return A character string containing the welcome message.
#' @export
#' @examples
#' hello()
hello <- function() {
  msg <- "Welcome to ClinTrialX!"
  Encoding(msg) <- "UTF-8"
  return(msg)   # Return the message for further use
}
