#' @export
serve.md_board <- function(x, id = "main", ...) {

  ace_placeholder <- shinyAce::aceEditor(
    "placeholder",
    mode = "r",
    theme = "github",
    height = "0px"
  )

  ace_placeholder[[2]]$attribs$style <- "display: none;"

  NextMethod(ace = ace_placeholder)
}
