test_that("has_ct detects nodes with exactly the c and t keys", {

  expect_true(has_ct(list(t = "Str", c = "x")))
  expect_true(has_ct(list(c = "x", t = "Str")))

  expect_false(has_ct(list(t = "Str")))
  expect_false(has_ct(list(a = 1, b = 2)))
  expect_false(has_ct(list(t = "Str", c = "x", extra = 1)))
})

test_that("astrapply returns non-list inputs unchanged", {

  expect_identical(astrapply(42L, function(t, c) NULL), 42L)
  expect_identical(astrapply("x", function(t, c) NULL), "x")
})

test_that("astrapply leaves an AST untouched when the filter returns NULL", {

  doc <- list(list(t = "Str", c = "hi"))

  expect_identical(astrapply(doc, function(t, c) NULL), doc)
})
