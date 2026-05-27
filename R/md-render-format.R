render_format <- function(ast, format, template, output) {
  format <- match.arg(format, supported_formats())

  pandoc_opts <- get_pandoc_args(format)

  if (!is.null(template) && nzchar(template)) {
    trg <- file.path(dirname(output), basename(template))
    file.copy(template, trg, overwrite = TRUE)
    on.exit(unlink(trg), add = TRUE)

    flag <- if (identical(format, "pptx")) "--reference-doc=" else "--template="
    pandoc_opts <- c(paste0(flag, basename(trg)), pandoc_opts)
  }

  rmarkdown::pandoc_convert(
    input   = ast,
    from    = "json",
    to      = format_pandoc_to(format),
    output  = output,
    options = pandoc_opts
  )
}
