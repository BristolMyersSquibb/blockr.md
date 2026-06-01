test_that("new_md_extension opts content into external control", {

  ext <- new_md_extension("# hello")

  expect_true(blockr.dock::is_dock_extension(ext))
  expect_identical(attr(ext, "external_ctrl"), "content")
})
