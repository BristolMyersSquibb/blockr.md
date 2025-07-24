#' Markdown board
#'
#' A markdown board pairs blockr functionality with a document builder.
#'
#' @param ... Board attributes
#' @param document Initial document
#'
#' @export
new_md_board <- function(..., document = character()) {
  blockr.ui::new_dag_board(
    ...,
    modules = new_md_module(content = document),
    class = "md_board"
  )
}
