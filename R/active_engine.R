#' Start a new ActiveEngine
#' @export
start <- function(name,
                  command = "",
                  language = name,
                  prompt = NULL,
                  keep_session = FALSE,
                  session_width = 80,
                  session_height = 24) {

  engine <- ActiveEngine$new(name = name,
                             command = command,
                             language = language,
                             prompt = prompt,
                             keep_session = keep_session,
                             session_width = session_width,
                             session_height = session_height)
  engine$start()
  invisible(engine)
}


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
    command = NULL,
    language = NULL,
    prompt = NULL,
    keep_session = NULL,
    session_width = NULL,
    session_height = NULL,


    initialize = function(name,
                          command = "",
                          language = name,
                          prompt = NULL,
                          keep_session = FALSE,
                          session_width = 80,
                          session_height = 24) {
      self$name <- name
      self$command <- command
      self$language <- language
      self$prompt <- prompt
      self$keep_session <- keep_session
      self$session_width <- session_width
      self$session_height <- session_height
    },

    start = function() {
      # Start a new rexpect session
      self$session <- rexpect::spawn(command = self$command,
                                     name = glue::glue("knitractive_{self$name}"),
                                     prompt = self$prompt,
                                     width = self$session_width,
                                     height = self$session_height)

      rexpect::expect_prompt(self$session)

      # Register the engine with Knitr
      knitr::knit_engines$set(setNames(list(private$execute), self$name))

      invisible(self)
    },


    stop = function() {
      rexpect::exit(self$session)
      invisible(self)
    },


    scroll = function(num_lines) {
      private$prev_output_length <- private$prev_output_length + num_lines
      invisible(self)
    },


    finalize = function() {
      if (!self$keep_session) {
        self$stop()
      }
    }
  ),

  private = list(
    prev_output_length = 1,

    execute = function(options) {
      if ((length(options$eval) == 1L) && !options$eval) {
        return(knitr::engine_output(options = options, code = options$code, out = NULL))
      }
      if (length(options$scroll) == 0L) options$scroll <- TRUE
      if (length(options$fullscreen) == 0L) options$fullscreen <- FALSE
      if (length(options$trailing_spaces) == 0L) options$trailing_spaces <- FALSE
      if (length(options$keep_last_prompt) == 0) options$keep_last_prompt <- FALSE
      if (length(options$marker) == 0L) options$marker <- "#!"
      if (length(options$echo) == 0L) options$echo <- TRUE
      if (length(options$escape) == 0L) options$escape <- FALSE
      if (length(options$callouts) == 0L) options$callouts <- list()

      options$session <- self$session
      do.call(rexpect::send_script, options)

      # Get output generated in this session
      if (options$fullscreen) {
        output <- rexpect::read_screen(self$session,
                                       escape = options$escape,
                                       trailing_spaces = TRUE)
      } else {
        output <- rexpect::read_output(self$session,
                                       private$prev_output_length,
                                       length(self$session),
                                       escape = options$escape,
                                       trailing_spaces = options$trailing_spaces)
      }

      # Replace all empty lines with a space to prevent R Markdown from trimming
      output <- stringr::str_replace(output, "^$", " ")

      # Remove all "empty" lines due to not having a screen full of output
      if (length(output) <= tmuxr::height(self$session)) {
        while ((length(output) > 0) && grepl("^ $", tail(output, 1))) {
          output <- head(output, -1)
        }
      }

      # Remove last line if it only contains prompt
      if (!options$keep_last_prompt &&
          !options$fullscreen &&
          rexpect::ends_with_prompt(self$session)) {
        output <- head(output, -1)
      }

      # Add empty lines to enforce fullscreen
      if (options$fullscreen) {
        #options$engine <- "text"
        output <- c(output,
                    rep(" ", tmuxr::height(self$session) - length(output)))
      }

      # Apply callouts=list(1, -1, "wc")
      callouts <- options$callouts
      if (is.null(names(callouts))) {
        names(callouts) <- as.character(seq_along(callouts))
      }
      for (num in names(callouts)) {
        position <- callouts[[num]]
        if (is.numeric(position)) {
          if (position < 1) {
            position <- length(output) + position + 1
          }
        } else {
          position <- which(grepl(position, output))[1]
        }
        output[position] <- paste0(output[position], " # <", num, ">")
      }

      # Remove lines based on indices
      remove_idx <- unlist(purrr::keep(options$remove, is.numeric))
      if (length(remove_idx) > 0L) {
        to_remove <- ifelse(remove_idx > 0, remove_idx, length(output) + remove_idx + 1)
        output <- output[-to_remove]
      }

      # Remove lines based on patterns
      remove_patterns <- unlist(purrr::keep(options$remove, is.character))
      for (p in remove_patterns) {
        output <- output[!grepl(p, output)]
      }

      # Scroll
      if (options$scroll) private$prev_output_length <- length(self$session)

      knitr::engine_output(options = options, code = output, out = NULL)
    }
  )
)

