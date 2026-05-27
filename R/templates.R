supported_formats <- function() c("pptx", "pdf", "html")

format_ext <- function(format) {
  c(pptx = "pptx", pdf = "tex", html = "html")[[format]]
}

format_pandoc_to <- function(format) {
  c(pptx = "pptx", pdf = "latex", html = "html5")[[format]]
}

format_download_ext <- function(format) {
  c(pptx = "pptx", pdf = "pdf", html = "html")[[format]]
}

get_template_choices <- function(format = "pptx") {
  get_template_opts(format)
}

get_default_template <- function(format = "pptx") {
  names(get_template_opts(format))[1L]
}

get_template_opts <- function(format = "pptx") {
  opt <- if (identical(format, "pptx")) "md_template" else paste0("md_template_", format)
  blockr_option(opt, default_template(format))
}

get_pandoc_args <- function(format) {
  defaults <- list(
    pptx = c("--slide-level=2"),
    pdf  = character(),
    html = c("--standalone", "--embed-resources")
  )
  blockr_option(paste0("md_pandoc_args_", format), defaults[[format]])
}

#' Default template option
#'
#' For `pptx` returns the bundled reference-doc. For `pdf` and `html` returns
#' the empty string — pandoc then uses its own built-in template, which always
#' matches the installed pandoc version (avoids macro-skew errors like
#' undefined `\pandocbounded` when the bundled template predates the pandoc
#' producing the document).
#'
#' @param format One of `"pptx"`, `"pdf"`, `"html"`.
#' @return Named character vector.
#'
#' @examples
#' default_template()
#' default_template("pdf")
#'
#' @export
default_template <- function(format = "pptx") {
  format <- match.arg(format, supported_formats())
  if (identical(format, "pptx")) {
    c(`Pandoc Default` = pkg_file("templates", "pandoc-default.pptx"))
  } else {
    c(`Pandoc Default` = "")
  }
}

pdf_available <- function() {
  nzchar(Sys.which("pdflatex")) ||
    nzchar(Sys.which("xelatex")) ||
    (requireNamespace("tinytex", quietly = TRUE) && tinytex::is_tinytex())
}

available_formats <- function() {
  fmts <- supported_formats()
  if (!pdf_available()) fmts <- setdiff(fmts, "pdf")
  fmts
}
