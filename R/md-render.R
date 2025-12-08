#' @param dir Where to place files (like images)
#' @param value Current md block value
#' @rdname new_md_extension
#' @export
md_render <- function(x, value, dir = tempdir(), ...) {
  UseMethod("md_render", x)
}

#' @rdname new_md_extension
#' @export
md_render.md_text <- function(x, value, dir = tempdir(), ...) {
  structure(md_to_json(x)[["blocks"]], class = "lolobo")
}

#' @rdname new_md_extension
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

#' @rdname new_md_extension
#' @export
md_render.ggplot <- function(x, ...) {
  # Store patchwork info in environment for recordedplot to access
  is_patchwork <- inherits(x, "patchwork")
  md_render(evaluate::evaluate("x"), ..., .is_patchwork = is_patchwork)
}

#' @param x Plot
#' @param .is_patchwork Is plot a patchwork plot?
#' @rdname new_md_extension
#' @export
md_render.recordedplot <- function(
  x,
  value,
  dir = tempdir(),
  ...,
  .is_patchwork = FALSE
) {
  # Use wider dimensions for patchwork grid plots
  fig_width <- if (.is_patchwork) 14 else 6.5
  fig_height <- if (.is_patchwork) 5 else 4.5

  opts <- list(
    label = "abc",
    fig.width = fig_width,
    fig.height = fig_height,
    dev = "png",
    fig.ext = "png",
    dpi = 72,
    fig.show = TRUE,
    fig.path = paste0(dir, "/")
  )

  res <- knitr::sew(x, opts)

  md_render(new_file(res, dir), value, dir, ...)
}

#' @rdname new_md_extension
#' @export
md_render.evaluate_evaluation <- function(x, ...) {
  hit <- lgl_ply(x, inherits, "recordedplot")

  stopifnot(sum(hit) == 1L)

  # Pass through the .is_patchwork parameter
  md_render(x[[which(hit)]], ...)
}

#' @method md_render data.frame
#' @rdname new_md_extension
#' @export
md_render.data.frame <- function(x, ...) {
  md_render(flextable::flextable(utils::head(x)), ...)
}

#' @rdname new_md_extension
#' @export
md_render.gt_tbl <- function(x, value, dir = tempdir(), ...) {
  res <- tempfile(tmpdir = dir, fileext = ".png")
  tmp <- tempfile(fileext = ".html")

  on.exit(unlink(tmp))

  html <- gt::as_raw_html(x)

  htmltools::save_html(html, tmp)

  webshot2::webshot(tmp, res, delay = 0, quiet = TRUE)

  img <- magick::image_read(res)
  crp <- magick::image_trim(img)

  magick::image_write(crp, res, format = "png")

  md_render(new_file(res, dir), value, dir, ...)
}

#' @rdname new_md_extension
#' @export
md_render.flextable <- function(x, ...) {
  # Get positioning from attributes or use defaults
  offx <- attr(x, "pptx_left", exact = TRUE)
  if (is.null(offx)) {
    offx <- 1
  }

  offy <- attr(x, "pptx_top", exact = TRUE)
  if (is.null(offy)) {
    offy <- 2
  }

  cx <- attr(x, "pptx_width", exact = TRUE)
  if (is.null(cx)) {
    cx <- 10
  }

  cy <- attr(x, "pptx_height", exact = TRUE)
  if (is.null(cy)) {
    cy <- 6
  }

  gen_raw_pml <- get("gen_raw_pml", envir = asNamespace("flextable"),
                     mode = "function", inherits = FALSE)

  md_raw(
    "openxml",
    gen_raw_pml(
      x,
      uid = sample(seq_len(10 ^ 9), 1L),
      offx = offx,
      offy = offy,
      cx = cx,
      cy = cy
    )
  )
}
