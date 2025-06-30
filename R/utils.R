new_file <- function(x, dir) {

	file <- basename(x)

  stopifnot(file.exists(file.path(dir, file)))

	structure(file, class = "file")
}
