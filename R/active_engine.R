#' Class providing ActiveEngine object.
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
ActiveEngine <- R6Class(
  "ActiveEngine",
  public = list(
    session = NULL,
    name = NULL,
    shell_command = NULL,
    prompt = NULL,
    lexer = NULL,
    keep_session = FALSE,


    initialize = function(name, shell_command, prompt, lexer, keep_session = FALSE) {
      self$name <- name
      self$shell_command <- shell_command
      self$prompt <- prompt
      self$lexer <- lexer
      self$keep_session <- keep_session
    },


    start = function() {
      self$session <- tmuxr::new_session(name = paste0("knitr_active_engine_",
                                                       self$name),
                                         shell_command = self$shell_command,
                                         prompt = self$prompt)

      tmuxr::wait_for_prompt(self$session)
      knitr::knit_engines$set(setNames(list(private$execute), self$name))
      invisible(self)
    },


    stop = function() {
      tmuxr::kill_session(self$session)
      invisible(self)
    },


    finalize = function() {
      if (!self$keep_session) {
        self$stop()
      }
    }
  ),

  private = list(
    prev_output_length = 0,


    execute = function(options) {
      if (length(options$start) == 0) options$start = -1000000L
      if (length(options$highlight) == 0) options$highlight = TRUE
      if (length(options$trim) == 0) options$trim = TRUE
      if (length(options$line_option_marker) == 0) {
        options$line_option_marker = "#~"
      }

      lines <- options$code

      for (line in lines) {
        line_options <- parse_line_options(line, options$line_option_marker)
        line_options$session <- self$session
        do.call(execute_line, line_options)
      }

      output <- tmuxr::capture_pane(self$session,
                                    trim = options$trim,
                                    start = options$start)

      new_output_length <- length(output)
      if (options$start < 1) {
        output <- output[(private$prev_output_length + 1):new_output_length]
      }
      private$prev_output_length <- new_output_length
      paste0(output, collapse = "\n")

      output <- system2("pygmentize",
                        args = c("-l", ifelse(options$highlight,
                                              self$lexer,
                                              "text"),
                                 "-f", "html"),
                        input = output,
                        stdout = TRUE)

      paste0(output, collapse = "\n")
    }
  )
)


BashActiveEngine <- R6Class(
  "BashActiveEngine",
  inherit = ActiveEngine,
  public = list(
    initialize = function() {
      super$initialize("bash")
    }
  )
)


PythonActiveEngine <- R6Class(
  "PythonActiveEngine",
  inherit = ActiveEngine,
  public = list(
    initialize = function(name = "python",
                          shell_command = "python",
                          prompt = "^(>>>|\\.\\.\\.)$",
                          lexer = "pycon",
                          keep_session = FALSE) {
      super$initialize(name, shell_command, prompt, lexer, keep_session)
    }
  )
)
