new_file <- function(x, dir) {
  file <- basename(x)

  stopifnot(file.exists(file.path(dir, file)))

  structure(file, class = "file")
}

ace_theme <- function(session = getDefaultReactiveDomain()) {
  switch(
    get_board_option_or_default("dark_mode", session),
    light = "katzenmilch",
    dark = "dracula"
  )
}

last <- function(x) x[[length(x)]]
