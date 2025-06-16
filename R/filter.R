apply_block_filter <- function(doc, blocks,
                               output = tempfile(fileext = ".pdf")) {

  dir <- tempfile()

  dir.create(dir)

  on.exit(unlink(dir, recursive = TRUE))

  res <- filter_md(
    block_filter,
    blocks = blocks,
    temp_dir = normalizePath(dir),
    doc = doc
  )

  on.exit(unlink(res), add = TRUE)

  rmarkdown::pandoc_convert(
    input = res,
    from = "json",
    to = "pdf",
    output = output
  )

  invisible(output)
}

block_filter <- function(key, value, blocks, temp_dir) {

  if (key == "Image" && grepl("^blockr://", value[[3L]][[1L]])) {

    id <- sub("^blockr://", "", value[[3L]][[1L]])

    stopifnot(id %in% names(blocks))

    md_render(
      blocks[[id]](),
      value,
      temp_dir
    )
  }
}

filter_md <- function(fun, ..., doc, output = tempfile(fileext = ".json")) {

  tmp <- tempfile(fileext = ".md")
  ast <- tempfile(fileext = ".json")

  on.exit(unlink(c(tmp)))

  writeLines(doc, tmp)

  rmarkdown::pandoc_convert(
    input = tmp,
    from = "markdown",
    to = "json",
    output = ast
  )

  json <- jsonlite::read_json(ast, flatten = TRUE)
  proc <- astrapply(json, fun, ...)

  jsonlite::write_json(
    proc,
    output,
    auto_unbox = TRUE,
    null = "null"
  )

  invisible(output)
}

# the following is in parts lifted from pandocfilters due to S3 name clashes
astrapply <- function(x, fun, ...) {

  astrapply_append <- function(obj, ...) {

    res <- astrapply(...)

    if (is.null(res)) {
      obj[length(obj) + 1] <- list(NULL)
    } else {
      obj[[length(obj) + 1]] <- res
    }

    obj
  }

  if (!is.list(x)) {
    return(x)
  }

  if (is.null(names(x))) {

    obj <- list()

    for (item in x) {

      if (is.list(item) && ("t" %in% names(item))) {

        res <- fun(item[["t"]], item[["c"]], ...)

        if (is.null(res)) {

          obj <- astrapply_append(obj, item, fun, ...)

        } else if (is.list(res) && is.null(names(res))) {

          for (z in res) {
            obj <- astrapply_append(obj, z, fun, ...)
          }

        } else {
          obj <- astrapply_append(obj, res, fun, ...)
        }

      } else {
        obj <- astrapply_append(obj, item, fun, ...)
      }
    }

    return(obj)
  }

  lapply(x, astrapply, fun, ...)
}

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
