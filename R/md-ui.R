#' @param content Initial content
#' @rdname new_md_board
#' @export
gen_md_ui <- function(content = character()) {

  function(id, board, ...) {

    id <- NS(id, "doc")

    tagList(
      shinyAce::aceEditor(
        NS(id, "ace"),
        content,
        mode = "markdown"
      ),
      actionButton(
        NS(id, "render"),
        "Render"
      ),
      fileInput(
        NS(id, "template"),
        "Powerpoint template"
      )
    )
  }
}
