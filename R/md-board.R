#' Markdown board
#'
#' A markdown board pairs blockr functionality with a document builder.
#'
#' @param ... Further (metadata) attributes
#' @param document Initial document
#'
#' @export
new_md_board <- function(..., document = character()) {
	new_board(
    ...,
    class = "md_board",
    document = document
  )
}

#' @param x Board object
#' @rdname new_md_board
#' @export
is_md_board <- function(x) {
  is_board(x) && inherits(x, "md_board")
}

#' @rdname new_md_board
#' @export
board_doc <- function(x) {
  stopifnot(is_md_board(x))
  x[["document"]]
}

#' @param value Replacement value
#' @rdname new_md_board
#' @export
`board_doc<-` <- function(x, value) {
  stopifnot(is_md_board(x))
  x[["document"]] <- value
  validate_board(x)
}

#' @export
validate_board.md_board <- function(x) {

  x <- NextMethod()

  doc <- board_doc(x)

  stopifnot(is.character(doc))

  x
}
