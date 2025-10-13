#' @param pptx_template Path to custom PowerPoint template. Use \code{blockr_template("pandoc-default.pptx")}
#'   for the bundled default template. Default is NULL (no template)
#' @rdname new_md_board
#' @export
gen_md_server <- function(pptx_template = NULL) {
  if (length(pptx_template)) {
    pptx_template <- normalizePath(pptx_template, mustWork = TRUE)
  }

  function(id, board, update, session, parent, ...) {
    moduleServer(
      id,
      function(input, output, session) {
        # Reactive value to store available block IDs
        available_block_ids <- reactiveVal(character())

        # Reactive value for validation message
        validation_message <- reactiveVal("")

        # Fix horizontal scrolling on initial load
        observe(
          {
            editor_id <- session$ns("ace")

            # Insert JavaScript to force word wrap and resize editor
            shiny::insertUI(
              selector = "body",
              where = "beforeEnd",
              immediate = TRUE,
              ui = tags$script(HTML(sprintf(
                "
              (function() {
                function setupEditor() {
                  if (typeof ace === 'undefined') {
                    setTimeout(setupEditor, 200);
                    return;
                  }
                  var editorElement = document.getElementById('%s');
                  if (!editorElement) {
                    setTimeout(setupEditor, 200);
                    return;
                  }
                  try {
                    var editor = ace.edit('%s');
                    // Force word wrap to be enabled
                    editor.getSession().setUseWrapMode(true);
                    // Resize after a delay to fix initial layout
                    setTimeout(function() {
                      editor.resize(true);
                    }, 500);
                  } catch(e) {
                    console.error('Error setting up editor:', e);
                  }
                }
                setupEditor();
              })();
            ",
                editor_id,
                editor_id
              )))
            )
          },
          priority = -100
        )

        # Update block IDs for autocomplete when blocks change
        observe({
          block_ids <- names(board$blocks)

          # Store block IDs for validation
          available_block_ids(block_ids)

          # Create completion list with full markdown image syntax
          completions <- paste0("![](blockr://", block_ids, ")")

          # Update autocomplete list
          shinyAce::updateAceEditor(
            session,
            "ace",
            autoCompleters = c("static"),
            autoCompleteList = list(blocks = completions)
          )

          # Update again after a delay to ensure it takes effect on first load
          later::later(
            function() {
              shinyAce::updateAceEditor(
                session,
                "ace",
                autoCompleters = c("static"),
                autoCompleteList = list(blocks = completions)
              )
            },
            delay = 1
          )
        })

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

        # Helper function to extract block IDs from markdown
        extract_block_ids_from_markdown <- function(markdown_text) {
          if (length(markdown_text) == 0 || nchar(markdown_text) == 0) {
            return(character())
          }

          # Extract all blockr:// references using regex
          pattern <- "blockr://([a-zA-Z0-9_]+)"
          matches <- gregexpr(pattern, markdown_text, perl = TRUE)

          if (matches[[1]][1] == -1) {
            return(character())
          }

          # Extract the captured groups (block IDs)
          all_matches <- regmatches(markdown_text, matches)[[1]]
          # Remove the "blockr://" prefix
          block_ids <- gsub("^blockr://", "", all_matches)
          unique(block_ids)
        }

        # Debounced reactive for markdown content
        markdown_debounced <- reactive({
          input$ace
        }) %>%
          debounce(300)

        # Validate block IDs when markdown changes (debounced)
        observe({
          markdown <- markdown_debounced()

          if (length(markdown) == 0 || nchar(markdown) == 0) {
            validation_message("")
            return()
          }

          # Extract block IDs from markdown
          used_ids <- extract_block_ids_from_markdown(markdown)

          if (length(used_ids) == 0) {
            validation_message("")
            return()
          }

          # Check which IDs are invalid
          available_ids <- available_block_ids()
          invalid_ids <- setdiff(used_ids, available_ids)

          if (length(invalid_ids) > 0) {
            msg <- sprintf(
              "Warning: Invalid block ID%s: %s",
              if (length(invalid_ids) > 1) "s" else "",
              paste(invalid_ids, collapse = ", ")
            )
            validation_message(msg)
          } else {
            validation_message("")
          }
        })

        # Render validation message
        output$validation_message <- renderUI({
          msg <- validation_message()

          if (nchar(msg) == 0) {
            return(NULL)
          }

          div(
            class = "alert alert-danger",
            role = "alert",
            style = "margin-top: -5px; margin-bottom: 10px; padding: 8px 12px; font-size: 0.875rem;",
            tags$strong("Error: "),
            gsub("^Warning: ", "", msg)
          )
        })

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

            # Determine which template to use: custom upload > function
            # parameter > selected bundled template
            template_path <- NULL
            inp_temp <- input$template

            if (isTruthy(input$use_custom_template) && isTruthy(inp_temp)) {
              # Custom uploaded template (only if checkbox is checked and file
              # is uploaded)
              template_path <- inp_temp$datapath
            } else if (length(pptx_template)) {
              # Function parameter template
              template_path <- pptx_template
            } else if (!is.null(input$template_select)) {
              # Selected bundled template
              template_path <- blockr_template(input$template_select)
            }

            if (!is.null(template_path)) {
              trg <- file.path(dirname(file), "template.pptx")
              file.copy(template_path, trg, overwrite = TRUE)

              on.exit(unlink(trg))

              pandoc_opts <- c(
                paste0("--reference-doc=", basename(trg)),
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
