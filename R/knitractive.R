#' @import tmuxr
#'
#' @export
knitractive <- function(name, shell_command, prompt, lexer, ...) {

  session_name <- paste0("knitractive_", name)
  try(kill_session(session_from_name(session_name)), silent = TRUE)
  session <- new_session(session_name,
                         shell_command = shell_command,
                         prompt = prompt, ...)

  wait_for_prompt(session)

  session$prev_output_length <- 0

  engine <- function(options) {
    if (length(options$start) == 0) options$start = -1000000L
    if (length(options$highlight) == 0) options$highlight = TRUE
    if (length(options$trim) == 0) options$trim = TRUE
    if (length(options$line_option_marker) == 0) options$line_option_marker = "#~"

    lines <- options$code

    for (line in lines) {
      line_options <- parse_line_options(line, options$line_option_marker)
      line_options$session <- session
      do.call(execute_line, line_options)
    }

    output <- capture_pane(session, trim = options$trim, start = options$start)
    new_output_length <- length(output)
    if (options$start < 1) {
      output <- output[(session$prev_output_length + 1):new_output_length]
    }
    session$prev_output_length <<- new_output_length
    paste0(output, collapse = "\n")

    output <- system2("pygmentize",
                      args = c("-l", ifelse(options$highlight, lexer, "text"),
                               "-f", "html"),
                      input = output,
                      stdout = TRUE)

    paste0(output, collapse = "\n")
  }

  knitr::knit_engines$set(setNames(list(engine), name))

  halt <- function() {
    kill_session(session)
  }

 list(
   engine = engine,
   session = session,
   halt = halt
   )
}


#' @export
parse_line_options <- function(line, marker) {
  line_parts <- strsplit(line, marker)[[1]]
  if (length(line_parts) > 1) {
    line_options <- eval(parse(text = paste0("alist(",
                                             paste0(line_parts[2:length(line_parts)], collapse = ","),
                                             ")"),
                               keep.source = FALSE))
  } else {
    line_options <- list()
  }

  line_options$code <- line_parts[1]
  line_options
}


#' @export
execute_line <- function(session,
                         code,
                         literal = TRUE,
                         enter = literal,
                         delay_before = 0,
                         pause_inbetween = 0.1,
                         sleep_after = 0,
                         wait_for_prompt = literal)  {

  if (delay_before > 0) wait(session, delay_before)
  if (literal) {
    send_keys(session, code, literal = TRUE)
  } else {
    parts <- strsplit(code, " ")[[1]]
    if (length(parts) < 2L) {
      send_keys(session, parts[1], literal = FALSE)
    } else {
      for (part in parts) {
        send_keys(session, part, literal = FALSE)
        wait(session, pause_inbetween)
      }
    }
  }
  if (enter) send_enter(session)
  if (sleep_after > 0) wait(session, sleep_after)
  if (wait_for_prompt) wait_for_prompt(session)
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


