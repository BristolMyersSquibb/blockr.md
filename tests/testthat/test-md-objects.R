test_that("md_str wraps a string as an inline Str node", {

  node <- md_str("hello")

  expect_s3_class(node, "md_inline")
  expect_identical(node$t, "Str")
  expect_identical(node$c, "hello")
})

test_that("as.md_inline coerces characters and collapses with spaces", {

  expect_s3_class(as.md_inline("a"), "md_inline")
  expect_identical(as.md_inline("a")$c, "a")
  expect_identical(as.md_inline(c("a", "b"))$c, "a b")
})

test_that("as.md_inline handles NULL and is idempotent on md_inline", {

  empty <- as.md_inline(NULL)
  expect_s3_class(empty, "md_inline")
  expect_length(empty, 0L)

  node <- md_str("x")
  expect_identical(as.md_inline(node), node)
})

test_that("as.md_loio wraps inputs in a list-of-inline-objects", {

  expect_s3_class(as.md_loio(NULL), "md_loio")
  expect_length(as.md_loio(NULL), 0L)

  from_chr <- as.md_loio("a")
  expect_s3_class(from_chr, "md_loio")
  expect_length(from_chr, 1L)
  expect_s3_class(from_chr[[1L]], "md_inline")

  expect_length(as.md_loio(md_str("z")), 1L)
})

test_that("as.md_loio is idempotent on md_loio", {

  loio <- as.md_loio(NULL)
  expect_identical(as.md_loio(loio), loio)
})

test_that("md_attr builds an attr node and rejects non-character classes", {

  expect_s3_class(md_attr(), "md_attr")
  expect_error(md_attr(classes = 1L))
})

test_that("md_raw and md_figure build their respective nodes", {

  raw <- md_raw("html", "<b>x</b>")
  expect_s3_class(raw, "md_raw")
  expect_identical(raw$t, "RawBlock")
  expect_identical(raw$c, list("html", "<b>x</b>"))

  expect_s3_class(md_figure(list()), "md_figure")
})
