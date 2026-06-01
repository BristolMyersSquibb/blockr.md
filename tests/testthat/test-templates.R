test_that("default_template is a single named template option", {

  tmpl <- default_template()

  expect_type(tmpl, "character")
  expect_length(tmpl, 1L)
  expect_named(tmpl, "Pandoc Default")
})

test_that("template option helpers fall back to the default", {

  expect_identical(get_default_template(), "Pandoc Default")
  expect_named(get_template_choices(), "Pandoc Default")
})
