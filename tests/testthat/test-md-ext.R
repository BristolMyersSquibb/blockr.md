test_that("new_md_extension opts content into external control", {

  ext <- new_md_extension("# hello")

  expect_true(blockr.dock::is_dock_extension(ext))
  expect_identical(attr(ext, "external_ctrl"), "content")
})

test_that("new_md_extension describes the blockr:// syntax", {

  desc <- blockr.dock::extension_description(new_md_extension())

  expect_type(desc, "character")
  expect_length(desc, 1L)
  expect_match(desc, "blockr://<block_id>", fixed = TRUE)
})
