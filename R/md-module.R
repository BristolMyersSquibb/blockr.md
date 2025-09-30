new_md_module <- function(id = "document", title = "Document builder",
                          content = character(), pptx_template = NULL) {

  blockr.ui::new_board_module(
    gen_md_ui(content),
    gen_md_server(pptx_template),
    on_restore = function(board, parent, session, ...) {

      req(parent$module_state$document())

      shinyAce::updateAceEditor(
        session,
        "ace",
        parent$module_state$document()
      )

      invisible()
    },
    id = id,
    title = title,
    class = "md_module"
  )
}
