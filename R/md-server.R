#' @param update,session,parent See [blockr.ui::main_server()]
#' @rdname new_md_board
#' @export
md_server <- function(board, update, session, parent, ...) {
  moduleServer(
    "doc",
    function(input, output, session) {

      observeEvent(
        get_board_option_or_default("dark_mode"),
        shinyAce::updateAceEditor(
          session,
          "ace",
          theme = ace_theme()
        )
      )

      res <- reactiveVal()

      observeEvent(input$ace, res(input$ace))

      observeEvent(
        req(parent$refreshed == "network"),
        shinyAce::updateAceEditor(
          session,
          "ace",
          parent$module_state$document()
        )
      )

      ast <- tempfile(fileext = ".json")
      tmp <- tempfile()

      observeEvent(
        input$render,
        {
          req(input$ace)

          dir.create(tmp)

          filter_md(
            block_filter,
            blocks = lst_xtr(board$blocks, "server", "result"),
            temp_dir = normalizePath(tmp),
            doc = input$ace,
            output = ast
          )

          md <- tempfile()
          on.exit(unlink(md))

          rmarkdown::pandoc_convert(
            input = ast,
            from = "json",
            to = "markdown",
            output = md
          )

          showModal(
            modalDialog(
              title = "MD preview",
              shinyAce::aceEditor(
                "preview",
                readLines(md),
                mode = "markdown",
                theme = ace_theme(),
                readOnly = TRUE
              ),
              size = "l",
              footer = tagList(
                downloadButton(
                  session$ns("dl_ppt"),
                  label = "Download PPT",
                  class = "btn-success"
                ),
                actionButton(
                  session$ns("close_modal"),
                  label = "Close",
                  class = "btn-danger"
                )
              )
            )
          )
        }
      )

      output$dl_ppt <- downloadHandler(
        function() paste0(
          "topline_",
          format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
          ".pptx"
        ),
        function(file) rmarkdown::pandoc_convert(
          input = ast,
          from = "json",
          to = "pptx",
          output = file
        )
      )

      observeEvent(
        input$close_modal,
        {
          unlink(ast)
          unlink(tmp, recursive = TRUE)
          removeModal()
        }
      )

      res
    }
  )
}
