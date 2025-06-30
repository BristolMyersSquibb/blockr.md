md_image <- function(target, text, caption = "", attr = md_attr()) {

  if (rmarkdown::pandoc_version() < "1.16") {

    res <- list(
      t = "Image",
      c = list(as.md_loio(text), list(target, caption))
    )

  } else {

    res <- list(
      t = "Image",
      c = list(attr, as.md_loio(text), list(target, caption))
    )
  }

  structure(res, class = c("md_inline", "list"))
}

md_attr <- function(identifier = "", classes = character(),
                    key_val_pairs = list()) {

  stopifnot(is.character(classes))

  structure(
    list(identifier, as.list(classes), key_val_pairs),
    class = c("md_attr", "list")
  )
}

md_str <- function(x) {
  structure(
    list(t = "Str", c = x),
    class = c("md_inline", "list")
  )
}

md_raw <- function(format, x) {
  structure(
    list(t = "RawBlock", c = list(format, x)),
    class = c("md_raw", "list")
  )
}

md_figure <- function(x, caption = "", attr = md_attr()) {
  structure(
    list(t = "Figure", c = list(attr, caption, x)),
    class = c("md_figure", "list")
  )
}

as.md_loio <- function(x) {
  UseMethod("as.md_loio")
}

#' @noRd
#' @export
as.md_loio.md_loio <- identity

#' @noRd
#' @export
as.md_loio.NULL <- function(x) {
  structure(list(), class = c("md_loio", "list"))
}

#' @noRd
#' @export
as.md_loio.md_inline <- function(x) {
  structure(list(x), class = c("md_loio", "list"))
}

#' @noRd
#' @export
as.md_loio.character <- function(x) {
  structure(list(as.md_inline(x)), class = c("md_loio", "list"))
}

#' @noRd
#' @export
as.md_loio.list <- function(x) {
  structure(lapply(x, as.md_inline), class = c("md_loio", "list"))
}

#' @noRd
#' @export
as.md_loio.list <- function(x) {
  structure(x, class = c("md_loio", "list"))
}

as.md_inline <- function(x) {
  UseMethod("as.md_inline")
}

#' @noRd
#' @export
as.md_inline.md_inline <- identity

#' @noRd
#' @export
as.md_inline.character <- function(x) {
  md_str(paste(x, collapse = " "))
}

#' @noRd
#' @export
as.md_inline.NULL <- function(x) {
  structure(list(), class = c("md_inline", "list"))
}
