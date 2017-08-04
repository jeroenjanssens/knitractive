#' @import tmuxr
#'
#' @export
register_active_engine <- function(name, shell_command, prompt, lexer) {

  session_name <- paste0("active_engine_", name)
  try(kill_session(session_from_name(session_name)), silent = TRUE)
  session <- new_session(session_name,
                         shell_command = shell_command,
                         prompt = prompt)

  wait_for_prompt(session)

  session$prev_output_length <- 0

  engine <- function(options) {
    lines <- options$code
    send_lines(session, lines)
    output <- capture_pane(session, trim = TRUE, start = -1000000L)
    new_output_length <- length(output)
    output <- output[(session$prev_output_length + 1):new_output_length]
    session$prev_output_length <<- new_output_length
    paste0(output, collapse = "\n")

    html <- system2("pygmentize",
                    args = c("-l", lexer, "-f", "html"),
                    input = output,
                    stdout = TRUE)

    paste0(html, collapse = "\n")
  }

 knitr::knit_engines$set(setNames(list(engine), name))

 invisible(session)
}

#' @export
add_style <- function(style, border = TRUE) {
  css <- system2("pygmentize",
  args = c("-S", style,
           "-f", "html",
           "-a", "'.highlight pre'"),
  stdout = TRUE)

  cat(paste0(c("<style>",
               css,
               if (!border) ".highlight pre { border: none }",
               "</style>"),
             collapse = "\n"))
}
