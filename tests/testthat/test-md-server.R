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
