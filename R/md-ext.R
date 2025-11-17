#' MD extension
#'
#' A markdown extension adds a document builder.
#'
#' @param content Initial document
#' @param ... Forwarded to [blockr.dock::new_dock_extension()]
#'
#' @rdname ext
#' @export
new_md_extension <- function(content = character(), ...) {

  blockr.dock::new_dock_extension(
    gen_md_server(NULL),
    gen_md_ui(content),
    name = "Document",
    class = "md_extension",
    ...
  )
}
