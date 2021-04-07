
#' @export
html_document <- function(engines = NULL, ...) {
  for (name in names(engines)) {
    v <- engines[[name]]

    command <- v$command
    if (!is.null(v$docker_image)) {
      command <- rexpect::cmd_docker(command, docker_image)
    }
    message(v$prompt)

    knitractive::start(name,
                       command,
                       language = v$language,
                       prompt = v$prompt,
                       keep_session = v$keep_session,
                       session_width = v$session_width,
                       session_height = v$session_height)
  }

  rmarkdown::html_document(...)
}
