get_template_choices <- function() {
  get_template_opts()
}

get_default_template <- function() {
  names(get_template_opts())[1L]
}

get_template_opts <- function() {
  blockr_option("md_template", default_template())
}

#' Default template option
#'
#' @return Named character vector for the default template
#'
#' @examples
#' default_template()
#'
#' @export
default_template <- function() {
  c(`Pandoc Default` = pkg_file("templates", "pandoc-default.pptx"))
}
