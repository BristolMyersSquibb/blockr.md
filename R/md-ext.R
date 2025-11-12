#' Document extension
#'
#' Create a markdown document, using blockr outputs.
#'
#' @param content Document content passed as character vector
#' @param template (Optional) template for rendering via pandoc
#' @param ... Forwarded to [blockr.dock::new_dock_extension()]
#'
#' @rdname ext
#' @export
new_md_extension <- function(content = character(), template = NULL, ...) {
  blockr.dock::new_dock_extension(
    gen_md_server(template),
    gen_md_ui(content),
    name = "Document",
    class = "md_extension",
    ...
  )
}
