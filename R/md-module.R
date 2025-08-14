new_md_module <- function(
  id = "document",
  title = "Document builder",
  content = character(),
  pptx_template = file.path()
) {
  blockr.ui::new_board_module(
    gen_md_ui(content),
    gen_md_server(pptx_template),
    id = id,
    title = title,
    class = "md_module"
  )
}
