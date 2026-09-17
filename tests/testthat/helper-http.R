fake_http_response <- function(body = "",
                               status = 200L,
                               headers = list(),
                               content_type = "text/csv; charset=UTF-8") {
  if (is.null(headers[["Content-Type"]])) {
    headers[["Content-Type"]] <- content_type
  }
  structure(
    list(
      url = "https://clinicaltrials.gov/api/v2/test",
      status_code = as.integer(status),
      headers = headers,
      all_headers = list(),
      cookies = data.frame(),
      content = charToRaw(enc2utf8(body)),
      date = Sys.time(),
      times = numeric(),
      request = list()
    ),
    class = "response"
  )
}
