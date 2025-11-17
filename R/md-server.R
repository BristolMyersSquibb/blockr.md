#' @param template Path to custom PowerPoint template. Use
#' `blockr_template("pandoc-default.pptx")` for the bundled default template.
#' Default is NULL (no template)
#' @rdname new_md_board
#' @export
gen_md_server <- function(template = NULL) {
  if (length(template)) {
    template <- normalizePath(template, mustWork = TRUE)
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

        res_doc <- reactiveVal()

        observeEvent(input$ace, res(input$ace))

        res_tpl <- reactive(
          {
            inp_temp <- input$template

            if (isTruthy(input$use_custom_template) && isTruthy(inp_temp)) {
              # Custom uploaded template (only if checkbox is checked and file
              # is uploaded)
              inp_temp$datapath
            } else if (length(template)) {
              # Function parameter template
              template
            } else if (!is.null(input$template_select)) {
              # Selected bundled template
              blockr_template(input$template_select)
            }
          }
        )

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
        markdown_debounced <- debounce(
          reactive(
            {
              input$ace
            }
          ),
          300
        )

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

        output$dl_ppt <- downloadHandler(
          filename = function() {
            paste0(
              "topline_",
              format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
              ".pptx"
            )
          },
          content = function(file) {
            req(input$ace)

            # Create temp files for processing
            ast <- tempfile(fileext = ".json")
            tmp <- tempfile()
            dir.create(tmp)

            # Ensure cleanup
            on.exit({
              unlink(ast)
              unlink(tmp, recursive = TRUE)
            })

            # Process markdown to AST
            filter_md(
              block_filter,
              blocks = lst_xtr(board$blocks, "server", "result"),
              temp_dir = normalizePath(tmp),
              doc = input$ace,
              output = ast
            )

            # Determine which template to use: custom upload > function
            # parameter > selected bundled template
            pandoc_opts <- NULL
            template_path <- res_tpl()

            if (!is.null(template_path)) {
              trg <- file.path(dirname(file), "template.pptx")
              file.copy(template_path, trg, overwrite = TRUE)

              on.exit(unlink(trg), add = TRUE)

              pandoc_opts <- c(
                paste0("--reference-doc=", basename(trg)),
                "--slide-level=2"
              )
            }

            # Convert AST to PowerPoint
            rmarkdown::pandoc_convert(
              input = ast,
              from = "json",
              to = "pptx",
              output = file,
              options = pandoc_opts
            )
          }
        )

        list(
          content = res_doc,
          template = res_tpl
        )
      }
    )
  }
}
