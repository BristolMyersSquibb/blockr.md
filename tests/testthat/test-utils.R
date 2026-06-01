test_that("last returns the final element", {

  expect_identical(last(1:3), 3L)
  expect_identical(last(list("a", "b")), "b")
})

test_that("new_file wraps an existing file and errors otherwise", {

  dir <- tempfile()
  dir.create(dir)
  writeLines("x", file.path(dir, "foo.txt"))

  res <- new_file("foo.txt", dir)
  expect_s3_class(res, "file")
  expect_identical(unclass(res), "foo.txt")

  expect_error(new_file("missing.txt", dir))
})
