#' Markdown board
#'
#' A markdown board pairs blockr functionality with a document builder.
#'
#' @param ... Board attributes
#' @param document Initial document
#' @param modules Additional modules to add to the board. See [blockr.ui::new_chat_module()].
#' @param pptx_template Path to a PowerPoint template.
#'
#' @export
new_md_board <- function(
  ...,
  document = character(),
  modules = list(),
  pptx_template = NULL
) {
  blockr.ui::new_dag_board(
    ...,
    modules = c(
      list(new_md_module(content = document, pptx_template = pptx_template)),
      modules
    ),
    class = "md_board"
  )
}
