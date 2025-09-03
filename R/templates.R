#' Get path to bundled PowerPoint templates
#'
#' This function returns the path to PowerPoint templates bundled with the
#' blockr.md package. If blockr.internal is available, it will prefer internal
#' templates for proprietary content, otherwise it falls back to default templates.
#'
#' @param template Name of the template file. If NULL, returns the templates directory.
#'   Available templates depend on whether blockr.internal is installed:
#'   - With blockr.internal: "bms-template.pptx" (from internal), "pandoc-default.pptx" (from blockr.md)
#'   - Without blockr.internal: "pandoc-default.pptx" (default)
#'
#' @return Character path to the template file or templates directory
#'
#' @examples
#' # Get BMS template (if blockr.internal is available, otherwise pandoc default)
#' template <- blockr_template("bms-template.pptx")
#'
#' # Get pandoc default template
#' default_template <- blockr_template("pandoc-default.pptx")
#'
#' # List all available templates
#' list.files(blockr_template())
#'
#' # Use with new_md_board
#' board <- new_md_board(pptx_template = blockr_template("bms-template.pptx"))
#'
#' @export
blockr_template <- function(template = NULL) {
  # Check for internal templates first
  if (requireNamespace("blockr.internal", quietly = TRUE)) {
    # Special handling for bms-template - use internal version if available
    if (!is.null(template) && template == "bms-template.pptx") {
      tryCatch({
        return(blockr.internal::blockr_internal_template("bms-template.pptx"))
      }, error = function(e) {
        # Fall through to default handling if internal template fails
      })
    }
  }
  
  # Default handling for blockr.md templates
  template_dir <- system.file("templates", package = "blockr.md")
  
  if (is.null(template)) {
    return(template_dir)
  }
  
  # If requesting bms-template but blockr.internal not available, use pandoc default
  if (template == "bms-template.pptx" && !requireNamespace("blockr.internal", quietly = TRUE)) {
    template <- "pandoc-default.pptx"
  }
  
  template_path <- file.path(template_dir, template)
  
  if (!file.exists(template_path)) {
    available_templates <- list.files(template_dir, pattern = "\\.pptx$")
    # Add internal templates to available list if package is installed
    if (requireNamespace("blockr.internal", quietly = TRUE)) {
      tryCatch({
        internal_templates <- blockr.internal::list_internal_templates()
        available_templates <- unique(c(internal_templates, available_templates))
      }, error = function(e) {
        # Continue with just blockr.md templates
      })
    }
    
    stop("Template '", template, "' not found. Available templates: ",
         paste(available_templates, collapse = ", "))
  }
  
  template_path
}

#' List available PowerPoint templates
#'
#' Lists templates available from blockr.md and blockr.internal (if installed).
#' Internal templates take precedence over public ones when both exist.
#'
#' @return Character vector of available template names
#'
#' @examples
#' list_blockr_templates()
#'
#' @export
list_blockr_templates <- function() {
  # Get templates from blockr.md
  template_dir <- system.file("templates", package = "blockr.md")
  md_templates <- list.files(template_dir, pattern = "\\.pptx$")
  
  all_templates <- md_templates
  
  # Add internal templates if available (these take precedence)
  if (requireNamespace("blockr.internal", quietly = TRUE)) {
    tryCatch({
      internal_templates <- blockr.internal::list_internal_templates()
      # Combine, with internal templates taking precedence
      all_templates <- unique(c(internal_templates, md_templates))
    }, error = function(e) {
      # Continue with just blockr.md templates
    })
  }
  
  all_templates
}