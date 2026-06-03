#' MD extension
#'
#' A markdown extension adds a document builder.
#'
#' @param content Initial document
#' @param ... Forwarded to [blockr.dock::new_dock_extension()]
#'
#' @export
new_md_extension <- function(content = character(), ...) {

  blockr.dock::new_dock_extension(
    gen_md_server(content),
    gen_md_ui(content),
    name = "Document",
    description = paste0(
      "Markdown document builder. Embed a block's rendered output by ",
      "referencing it with markdown image syntax: ",
      "`![caption](blockr://<block_id>)`, where `<block_id>` is the block ",
      "id from `list_blocks` and the alt text becomes the caption. Only ",
      "blocks on the board resolve."
    ),
    class = "md_extension",
    external_ctrl = "content",
    ...
  )
}
