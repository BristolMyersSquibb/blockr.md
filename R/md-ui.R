gen_md_ui <- function(content = character()) {
  function(id, board, ...) {
    ns <- NS(id)

    div(
      style = "padding: 16px;",
      tags$style(HTML(sprintf(
        "
        #%s i {
          display: none !important;
        }
      ",
        ns("dl")
      ))),
      shinyAce::aceEditor(
        ns("ace"),
        content,
        mode = "markdown",
        wordWrap = TRUE,
        showInvisibles = FALSE,
        autoComplete = "live",
        autoCompleters = c("static"),
        autoScrollEditorIntoView = FALSE,
      ),
      div(
        class = "text-muted",
        style = "margin-top: -10px; margin-bottom: 10px; font-size: 0.875rem;",
        tags$small("Type 'block' to see available block IDs for autocomplete")
      ),
      uiOutput(ns("validation_message")),
      div(
        class = "d-flex align-items-center",
        selectInput(
          ns("format_select"),
          NULL,
          choices = available_formats(),
          selected = "pptx",
          width = "100px"
        ),
        div(
          style = "margin-left: 8px; flex: 1;",
          uiOutput(ns("template_select_ui"))
        ),
        downloadButton(
          ns("dl"),
          "Download",
          class = "btn-outline-success btn-sm",
          style = "margin-left: 10px; margin-top: -18px; height: 36px; padding-top: 6.5px;"
        )
      ),
      uiOutput(ns("pdf_unavailable_note")),
      div(
        class = "mb-3",
        checkboxInput(
          ns("use_custom_template"),
          tags$small(class = "text-muted", "Use custom template"),
          value = FALSE
        ),
        conditionalPanel(
          condition = paste0("input['", ns("use_custom_template"), "']"),
          uiOutput(ns("custom_template_ui"))
        )
      )
    )
  }
}
