block_filter <- function(key, value, blocks, temp_dir) {

  if (key == "Para" && length(value) == 1L && has_ct(value[[1L]])) {

    res <- block_filter(value[[1L]][["t"]], value[[1L]][["c"]], blocks,
                        temp_dir)

    if (inherits(res, "md_raw") || inherits(res, "lolobo")) {
      return(res)
    }

  } else if (key == "Figure") {

    val <- value[[3L]][[1L]][["c"]][[1L]]

    if (has_ct(val)) {

      res <- block_filter(val[["t"]], val[["c"]], blocks, temp_dir)

      if (inherits(res, "md_raw")) {
        return(res)
      }

      stopifnot(inherits(res, "md_inline"))

      value[[3L]][[1L]][["c"]][[1L]] <- res

      res <- md_figure(
        value[[3L]],
        value[[2L]],
        value[[1L]]
      )

      return(res)

    } else {
      log_info("skipping figure replacement (unexpected structure)")
    }

  } else if (key == "Image") {

    uri <- value[[3L]][[1L]]

    if (is.character(uri) && length(uri) == 1L && grepl("^blockr://", uri)) {

      id <- sub("^blockr://", "", uri)

      stopifnot(id %in% names(blocks))

      res <- md_render(
        blocks[[id]](),
        value,
        temp_dir
      )

      return(res)
    }

    log_debug("skipping non blockr figure replacement")
  }

  NULL
}

has_ct <- function(x) {
  setequal(c("c", "t"), names(x))
}

md_to_json <- function(doc) {

  ast <- tempfile(fileext = ".json")
  tmp <- tempfile(fileext = ".md")

  on.exit(unlink(c(tmp, ast)))

  writeLines(doc, tmp)

  rmarkdown::pandoc_convert(
    input = tmp,
    from = "markdown",
    to = "json",
    output = ast
  )

  jsonlite::read_json(ast, flatten = TRUE)
}

filter_md <- function(fun, ..., doc, output = tempfile(fileext = ".json")) {

  json <- md_to_json(doc)
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

        } else if (inherits(res, "lolobo")) {

          obj <- c(obj, unclass(res))

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
