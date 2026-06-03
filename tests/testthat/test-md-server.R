server_args <- function() {
  list(
    board = list(blocks = list(), board = blockr.core::new_board()),
    update = NULL,
    session = NULL,
    parent = NULL
  )
}

test_that("content state is a reactiveVal seeded from the constructor", {

  shiny::testServer(
    gen_md_server("# seed"),
    args = server_args(),
    {
      expect_s3_class(session$returned$state$content, "reactiveVal")
      expect_identical(content_rv(), "# seed")
      expect_identical(session$returned$state$content(), "# seed")
    }
  )
})

test_that("editor edits flow into the content state, debounced", {

  shiny::testServer(
    gen_md_server(),
    args = server_args(),
    {
      session$setInputs(ace = "# edited")
      session$elapse(400)

      expect_identical(content_rv(), "# edited")
    }
  )
})

test_that("external writes are echo-guarded and can clear the content", {

  shiny::testServer(
    gen_md_server("# seed"),
    args = server_args(),
    {
      content_rv("# external")
      expect_identical(content_rv(), "# external")

      content_rv("# external")
      expect_identical(content_rv(), "# external")

      content_rv("")
      expect_identical(content_rv(), "")
    }
  )
})

test_that("an external write is pushed to the editor when it differs", {

  shiny::testServer(
    gen_md_server(),
    args = server_args(),
    {
      session$setInputs(ace = "# from editor")
      session$elapse(400)

      content_rv("# set externally")
      session$flushReact()

      expect_identical(content_rv(), "# set externally")
    }
  )
})

test_that("validation flags unknown block IDs and clears for plain content", {

  shiny::testServer(
    gen_md_server(),
    args = server_args(),
    {
      content_rv("![](blockr://missing_block)")
      session$flushReact()
      expect_match(validation_message(), "missing_block")
      expect_false(is.null(output$validation_message))

      content_rv("# just a heading")
      session$flushReact()
      expect_identical(validation_message(), "")
      expect_null(output$validation_message)
    }
  )
})

test_that("res_tpl honors an explicit selection and a custom upload", {

  shiny::testServer(
    gen_md_server(),
    args = server_args(),
    {
      session$setInputs(template_select = "/sel/template.pptx")
      expect_identical(res_tpl(), "/sel/template.pptx")

      session$setInputs(
        use_custom_template = TRUE,
        template = list(datapath = "/up/custom.pptx")
      )
      expect_identical(res_tpl(), "/up/custom.pptx")
    }
  )
})
