#' @param dir Where to place files (like images)
#' @param value Current md block value
#' @rdname new_md_board
#' @export
md_render <- function(x, value, dir = tempdir(), ...) {
	UseMethod("md_render", x)
}

#' @rdname new_md_board
#' @export
md_render.file <- function(x, value, dir = tempdir(), ...) {

  stopifnot(is.character(x), length(x) == 1L, ...length() == 0L)

  x <- file.path(dir, x)

  stopifnot(file.exists(x))

  md_image(
    target = paste0("file://", normalizePath(x)),
    text = value[[2L]],
    caption = value[[3L]][[2L]],
    attr = md_attr(
      identifier = value[[1L]][[1L]],
      classes = as.character(value[[1L]][[2L]]),
      key_val_pairs = value[[1L]][[3L]]
    )
  )
}

#' @rdname new_md_board
#' @export
md_render.ggplot <- function(x, ...) {
  md_render(evaluate::evaluate("x"), ...)
}

#' @rdname new_md_board
#' @export
md_render.recordedplot <- function(x, value, dir = tempdir(), ...) {

  opts <- list(
    label = "abc",
    fig.width = 6.5,
    fig.height = 4.5,
    dev = "pdf",
    fig.ext = "pdf",
    dpi = 72,
    fig.show = TRUE,
    fig.path = paste0(dir, "/")
  )

  res <- knitr::sew(x, opts)

  md_render(new_file(res, dir), value, dir, ...)
}

#' @rdname new_md_board
#' @export
md_render.evaluate_evaluation <- function(x, ...) {

  hit <- lgl_ply(x, inherits, "recordedplot")

  stopifnot(sum(hit) == 1L)

  md_render(x[[which(hit)]], ...)
}

#' @method md_render data.frame
#' @rdname new_md_board
#' @export
md_render.data.frame <- function(x, ...) {
  md_render(flextable::flextable(utils::head(x)), ...)
}

#' @rdname new_md_board
#' @export
md_render.gt_tbl <- function(x, value, dir = tempdir(), ...) {

  res <- tempfile(tmpdir = dir, fileext = ".pdf")
  tmp <- tempfile(fileext = ".html")

  on.exit(unlink(tmp))

  html <- gt::as_raw_html(x)

  htmltools::save_html(html, tmp)

  webshot2::webshot(tmp, res, delay = 0, quiet = TRUE)

  img <- magick::image_read_pdf(res)
  crp <- magick::image_trim(img)

  magick::image_write(crp, res, format = "pdf")

  md_render(new_file(res, dir), value, dir, ...)
}

#' @rdname new_md_board
#' @export
md_render.flextable <- function(x, ...) {

  md_raw(
    "openxml",
    flextable:::gen_raw_pml(
      x,
      uid = as.integer(runif(n = 1) * 10^9),
      offx = 1,
      offy = 2,
      cx = 10,
      cy = 6
    )
  )
}
