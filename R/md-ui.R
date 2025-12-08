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
        ns("dl_ppt")
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
          ns("template_select"),
          NULL,
          choices = get_template_choices(),
          selected = get_default_template(),
          width = "100%"
        ),
        downloadButton(
          ns("dl_ppt"),
          "Download",
          class = "btn-outline-success btn-sm",
          style = "margin-left: 10px; margin-top: -18px; height: 36px; padding-top: 6.5px;"
        )
      ),
      div(
        class = "mb-3",
        checkboxInput(
          ns("use_custom_template"),
          tags$small(class = "text-muted", "Use custom template"),
          value = FALSE
        ),
        conditionalPanel(
          condition = paste0("input['", ns("use_custom_template"), "']"),
          fileInput(
            ns("template"),
            NULL,
            placeholder = "Select .pptx template file",
            accept = ".pptx"
          )
        )
      )
    )
  }
}
