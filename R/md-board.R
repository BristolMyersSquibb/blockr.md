#' Markdown board
#'
#' A markdown board pairs blockr functionality with a document builder.
#'
#' @param ... Board attributes
#' @param document Initial document
#' @param pptx_template Path to a PowerPoint template.
#'
#' @export
new_md_board <- function(..., document = character(), pptx_template = NULL) {

  blockr.ui::new_dag_board(
    ...,
    modules = new_md_module(content = document, pptx_template = pptx_template),
    class = "md_board"
  )
}
