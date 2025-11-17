#' MD extension
#'
#' A markdown extension adds a document builder.
#'
#' @param document Initial document
#' @param template Path to a PowerPoint template.
#' @param ... Forwarded to [blockr.dock::new_dock_extension()]
#'
#' @rdname dag
#' @export
new_md_extension <- function(content = character(), template = NULL,
                              ...) {

  blockr.dock::new_dock_extension(
    gen_md_server(template),
    gen_md_ui(content),
    name = "Document",
    class = "md_extension",
    ...
  )
}
