#' @keywords internal
parse_line_options <- function(line, marker) {
  parts <- strsplit(line, marker)[[1]]
  if (length(parts) > 1) {
    line_options <- eval(parse(text = paste0("alist(",
                                             paste0(parts[2:length(parts)],
                                                    collapse = ","),
                                             ")"),
                               keep.source = FALSE))
  } else {
    line_options <- list()
  }

  line_options$code <- parts[1]
  line_options
}


#' @keywords internal
execute_line <- function(session,
                         code,
                         literal = TRUE,
                         enter = literal,
                         delay_before = 0,
                         pause_inbetween = 0.1,
                         sleep_after = 0,
                         wait_for_prompt = literal)  {

  if (delay_before > 0) tmuxr::wait(session, delay_before)
  if (literal) {
    tmuxr::send_keys(session, code, literal = TRUE)
  } else {
    parts <- strsplit(code, " ")[[1]]
    if (length(parts) < 2L) {
      tmuxr::send_keys(session, parts[1], literal = FALSE)
    } else {
      for (part in parts) {
        tmuxr::send_keys(session, part, literal = FALSE)
        tmuxr::wait(session, pause_inbetween)
      }
    }
  }
  if (enter) tmuxr::send_enter(session)
  if (sleep_after > 0) tmuxr::wait(session, sleep_after)
  if (wait_for_prompt) tmuxr::wait_for_prompt(session)
}
