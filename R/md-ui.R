#' @param id Namespace ID
#' @rdname new_md_board
#' @export
doc_ui <- function(id, x) {

  id <- NS(id, "doc")

  shinyAce::aceEditor(
    NS(id, "ace"),
    board_doc(x),
    mode = "markdown"
  )
}

#' @export
board_ui.md_board <- function(id, x, plugins = list(), ...) {

  tagList(
    toolbar_ui(id, x, plugins),
    board_ui(id, plugins[["notify_user"]], x),
    doc_ui(id, x),
    div(
      id = paste0(id, "_board"),
      stack_ui(id, x, edit_ui = plugins[["edit_stack"]]),
      block_ui(id, x, edit_ui = plugins[["edit_block"]])
    )
  )
}
