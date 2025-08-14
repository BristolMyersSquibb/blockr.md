#' @param pptx_template Path to custom PowerPoint template. Default is NULL
#' @rdname new_md_board
#' @export
gen_md_server <- function(pptx_template) {
  if (length(pptx_template)) {
    pptx_template <- file.path(pptx_template)
    stopifnot(file.exists(pptx_template))
  }

  function(board, update, session, parent, ...) {
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
          {
            req(parent$module_state$document)
            shinyAce::updateAceEditor(
              session,
              "ace",
              parent$module_state$document()
            )
          }
        )

        ast <- tempfile(fileext = ".json")
        tmp <- tempfile()

        observeEvent(
          input$render,
          {
            req(input$ace)

            dir.create(tmp)

            md <- tempfile()
            on.exit(unlink(md))

            shinycssloaders::showPageSpinner(
              {
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
                  to = "markdown",
                  output = md
                )
              }
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
          function() {
            paste0(
              "topline_",
              format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
              ".pptx"
            )
          },
          function(file) {
            pandoc_opts <- NULL
            if (length(pptx_template)) {
              # template has to be at the same level as the output file for pandoc
              file.copy(pptx_template, dirname(file), overwrite = TRUE)
              pandoc_opts <- c(
                sprintf(
                  "--reference-doc=%s",
                  basename(pptx_template)
                ),
                "--slide-level=2"
              )
            }

            rmarkdown::pandoc_convert(
              input = ast,
              from = "json",
              to = "pptx",
              output = file,
              options = pandoc_opts
            )
          }
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
}
