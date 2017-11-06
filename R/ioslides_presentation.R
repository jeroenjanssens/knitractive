#' @export
ioslides_presentation <- function(engine_name = NULL,
                          engine_command = NULL,
                          engine_prompt = NULL,
                          engine_lexer = NULL,
                          style_name = "perldoc",
                          style_border = FALSE,
                          keep_session = FALSE,
                          css = NULL,
                          ...) {

  # Start engine inside a tmux session
  engine <<- ActiveEngine$new(
    name = engine_name,
    shell_command = engine_command,
    prompt = engine_prompt,
    lexer = engine_lexer,
    keep_session = keep_session
  )
  engine$start()


  # Generate CSS for code chucks using pygmentize
  extra_css_file <- tempfile(pattern = "knitractive-", fileext = ".css")
  extra_css <- system2("pygmentize",
                       args = c("-S", style_name,
                                "-f", "html",
                                "-a", "'.highlight pre'"),
                 stdout = TRUE)

  cat(paste0(c("<style>",
               extra_css,
               if (!style_border) ".highlight pre { border: none }",
               "</style>"),
             collapse = "\n"), file = extra_css_file)

  css <- c(css, extra_css_file)

  rmarkdown::ioslides_presentation(css = css, ...)
}
