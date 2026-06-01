cat("--- system ---\n")
cat("OS:        ", Sys.info()[["sysname"]], Sys.info()[["release"]], "\n")
cat("R:         ", R.version.string, "\n")
cat("PATH:      ", Sys.getenv("PATH"), "\n\n")

cat("--- LaTeX engines ---\n")
for (eng in c("pdflatex", "xelatex", "lualatex")) {
  p <- Sys.which(eng)
  cat(sprintf("%-9s: %s\n", eng, if (nzchar(p)) p else "NOT FOUND"))
}

cat("\n--- tinytex ---\n")
have_tinytex <- requireNamespace("tinytex", quietly = TRUE)
cat("tinytex installed:", have_tinytex, "\n")
if (have_tinytex) {
  cat("tinytex::is_tinytex():", tinytex::is_tinytex(), "\n")
  cat("tinytex::tinytex_root():", tryCatch(tinytex::tinytex_root(), error = function(e) "ERROR"), "\n")
}

cat("\n--- pandoc ---\n")
cat("pandoc:", Sys.which("pandoc"), "\n")
cat("rmarkdown::pandoc_version():", as.character(rmarkdown::pandoc_version()), "\n")

cat("\n--- step 1: pandoc md -> pdf (no template, default engine) ---\n")
mdf <- tempfile(fileext = ".md")
writeLines("# Hi\n\nHello.\n", mdf)
out1 <- tempfile(fileext = ".pdf")
res1 <- tryCatch(
  rmarkdown::pandoc_convert(input = mdf, to = "latex", output = out1),
  error = function(e) conditionMessage(e),
  warning = function(w) conditionMessage(w)
)
cat("result:", if (is.null(res1)) "OK" else res1, "\n")
cat("file size:", if (file.exists(out1)) file.info(out1)$size else NA, "\n")

cat("\n--- step 2: pandoc md -> pdf with --pdf-engine=xelatex ---\n")
out2 <- tempfile(fileext = ".pdf")
res2 <- tryCatch(
  rmarkdown::pandoc_convert(input = mdf, to = "latex", output = out2,
                            options = c("--pdf-engine=xelatex")),
  error = function(e) conditionMessage(e)
)
cat("result:", if (is.null(res2)) "OK" else res2, "\n")
cat("file size:", if (file.exists(out2)) file.info(out2)$size else NA, "\n")

cat("\n--- step 3: render_format via blockr.md ---\n")
if (requireNamespace("blockr.md", quietly = TRUE)) {
  cat("blockr.md::pdf_available():", blockr.md:::pdf_available(), "\n")
  ast <- tempfile(fileext = ".json")
  rmarkdown::pandoc_convert(input = mdf, from = "markdown", to = "json", output = ast)
  out3 <- tempfile(fileext = ".pdf")
  res3 <- tryCatch(
    blockr.md:::render_format(ast, "pdf",
      template = blockr.md::default_template("pdf")[[1]],
      output = out3),
    error = function(e) conditionMessage(e)
  )
  cat("result:", if (is.null(res3)) "OK" else res3, "\n")
  cat("file size:", if (file.exists(out3)) file.info(out3)$size else NA, "\n")
} else {
  cat("blockr.md not installed; skipping.\n")
}

cat("\n--- done ---\n")
cat("If any step shows a LaTeX error, paste the full message.\n")
cat("If pdflatex is NOT FOUND but tinytex is_tinytex() is TRUE, you probably need\n")
cat("to add ~/Library/TinyTeX/bin/<arch>-darwin to PATH (or run\n")
cat("tinytex::r_texmf() from R, then restart R).\n")
