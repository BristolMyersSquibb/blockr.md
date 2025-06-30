block_filter <- function(key, value, blocks, temp_dir) {

  if (key == "Figure") {

    val <- value[[3L]][[1L]][["c"]][[1L]]

    if (setequal(c("c", "t"), names(val)) && identical(val[["t"]], "Image")) {

      uri <- val[["c"]][[3L]][[1L]]

      if (is.character(uri) && length(uri) == 1L && grepl("^blockr://", uri)) {

        id <- sub("^blockr://", "", uri)

        stopifnot(id %in% names(blocks))

        res <- md_render(
          blocks[[id]](),
          val[["c"]],
          temp_dir
        )

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
      }

      log_debug("skipping non blockr figure replacement")

    } else {
      log_info("skipping figure replacement (unexpected structure)")
    }
  }

  NULL
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
