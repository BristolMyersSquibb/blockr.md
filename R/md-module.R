new_md_module <- function(id = "document", title = "Document builder",
                          content = character()) {

  blockr.ui::new_board_module(
    gen_md_ui(content),
    md_server,
    id = id,
    title = title,
    class = "md_module"
  )
}
