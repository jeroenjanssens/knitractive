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
