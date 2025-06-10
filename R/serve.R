#' @export
serve.md_board <- function(x, id = rand_names(),
													 plugins = board_plugins(), ...) {

	NextMethod(callbacks = list(document_server))
}

document_server <- function(board, update, ...) {
  moduleServer(
    "doc",
    function(input, output, session) {
      observeEvent(
        get_board_option_or_default("dark_mode"),
        shinyAce::updateAceEditor(
          session,
          "ace",
          theme = switch(
            get_board_option_or_default("dark_mode"),
            light = "katzenmilch",
            dark = "dracula"
          )
        )
      )
    }
  )
}
