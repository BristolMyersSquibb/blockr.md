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

    id <- NS(id, "doc")

    tagList(
      shinyAce::aceEditor(
        NS(id, "ace"),
        content,
        mode = "markdown"
      ),
      actionButton(
        NS(id, "render"),
        "Render"
      ),
      div(
        style = "margin-bottom: 10px;",
        selectInput(
          NS(id, "template_select"),
          "PowerPoint Template",
          choices = get_template_choices(),
          selected = get_default_template()
        )
      ),
      fileInput(
        NS(id, "template"),
        "Upload Custom Template",
        placeholder = "Optional: Override with custom template"
      )
    )
  }
}
