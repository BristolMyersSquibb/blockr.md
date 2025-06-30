#' @export
serve.md_board <- function(x, id = rand_names(),
													 plugins = board_plugins(), ...) {

	NextMethod(callbacks = list(document_server))
}

document_server <- function(board, update, ...) {
  moduleServer(
    "doc",
    function(input, output, session) {

      temp_dir <- tempfile()

      if (!dir.exists(temp_dir)) {
        dir.create(temp_dir)
        onStop(function() unlink(temp_dir, recursive = TRUE))
      }

      addResourcePath(
        prefix = "doc_previews",
        directoryPath = temp_dir
      )

      observeEvent(
        get_board_option_or_default("dark_mode"),
        shinyAce::updateAceEditor(
          session,
          "ace",
          theme = switch(
            get_board_option_or_default("dark_mode"),
            light = "katzenmilch",
            dark = "dracula"
          )
        )
      )

      ast <- tempfile(fileext = ".json")
      pdf <- tempfile(tmpdir = temp_dir, fileext = ".pdf")
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

          rmarkdown::pandoc_convert(
            input = ast,
            from = "json",
            to = "pdf",
            output = pdf
          )

          showModal(
            modalDialog(
              title = "PDF preview",
              tags$embed(
                src = paste0("doc_previews/", basename(pdf)),
                type = "application/pdf",
                width = "100%",
                height = "500px"
              ),
              size = "xl",
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
          unlink(c(ast, pdf))
          unlink(tmp, recursive = TRUE)
          removeModal()
        }
      )
    }
  )
}
