#' Get template choices for UI
#'
#' Internal helper to get template choices based on available packages
#'
#' @return Named vector of template choices
#' @keywords internal
get_template_choices <- function() {
  if (requireNamespace("blockr.internal", quietly = TRUE)) {
    setNames(
      c("bms-template.pptx", "pandoc-default.pptx"),
      c("BMS Template (Internal)", "Pandoc Default")
    )
  } else {
    setNames(
      c("pandoc-default.pptx"),
      c("Pandoc Default")
    )
  }
}

#' Get default template selection
#'
#' Internal helper to get the default template selection
#'
#' @return Character string of default template
#' @keywords internal
get_default_template <- function() {
  if (requireNamespace("blockr.internal", quietly = TRUE)) {
    "bms-template.pptx"
  } else {
    "pandoc-default.pptx"
  }
}

#' @param content Initial content
#' @rdname new_md_board
#' @export
gen_md_ui <- function(content = character()) {
  function(id, board, ...) {
    ns <- NS(id)

    tagList(
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
        actionButton(
          ns("render"),
          "Render",
          class = "btn-success btn-sm",
          style = "margin-left: 10px; margin-top: -18px; height: 36px;"
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
