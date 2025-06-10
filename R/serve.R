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

      preview <- reactiveVal()

      observeEvent(
        input$render,
        {

          req(input$ace)

          preview(
            render_doc(input$ace, tempfile(tmpdir = temp_dir))
          )

          showModal(
            modalDialog(
              title = "PDF preview",
              tags$embed(
                src = paste0("doc_previews/", basename(preview())),
                type = "application/pdf",
                width = "100%",
                height = "500px"
              ),
              size = "xl",
              footer = actionButton(
                session$ns("close_modal"),
                label = "Close"
              )
            )
          )
        }
      )

      observeEvent(
        input$close_modal,
        {
          req(preview())
          removeModal()
          unlink(preview())
          preview(NULL)
        }
      )
    }
  )
}

render_doc <- function(doc, file = tempfile()) {

  tmp <- tempfile()
  on.exit(unlink(tmp))
  writeLines(doc, tmp)

  rmarkdown::render(
    tmp,
    output_format = "pdf_document",
    output_file = file
  )
}
