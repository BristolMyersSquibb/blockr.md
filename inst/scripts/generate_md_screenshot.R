#!/usr/bin/env Rscript

#' Generate Screenshot for blockr.md README Example
#'
#' This script generates a screenshot using the same approach as blockr.fsui
#' Uses webshot2::appshot() for reliable screenshot generation

# Check dependencies
if (!requireNamespace("webshot2", quietly = TRUE)) {
  stop("Please install webshot2: install.packages('webshot2')")
}

if (!requireNamespace("blockr.core", quietly = TRUE)) {
  stop("blockr.core package must be installed")
}

library(webshot2)

# Increase timeout for Shiny app launching
options(webshot.app.timeout = 120)

# Configuration
SCREENSHOT_WIDTH <- 1200
SCREENSHOT_HEIGHT <- 800
OUTPUT_DIR <- "man/figures"

# Create output directory if it doesn't exist
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

cat("Generating screenshot for blockr.md README example...\n")

# Helper function to create temporary app and take screenshot
create_md_screenshot <- function(filename) {
  cat(sprintf("Generating %s...\n", filename))

  tryCatch(
    {
      # Create temporary directory for the app
      temp_dir <- tempfile("blockr_md_app")
      dir.create(temp_dir)

      # Create minimal app.R file
      app_content <- sprintf(
        '
# Load the current development version
devtools::load_all("/Users/christophsax/git/blockr/blockr.md")
library(blockr.core)

# Run the app - THE EXACT README EXAMPLE
serve(
  new_md_board(
    blocks = c(
      a = new_dataset_block("iris"),
      b = new_scatter_block("Sepal.Length", "Sepal.Width")
    ),
    links = list(from = "a", to = "b", input = "data"),
    document = c(
      "# My title",
      "",
      "## Slide with table",
      "",
      "![](blockr://a)",
      "",
      "## Slide with plot",
      "",
      "![Sepal length vs width for iris species](blockr://b)"
    )
  )
)
    '
      )

      writeLines(app_content, file.path(temp_dir, "app.R"))

      # Take screenshot using appshot (same as blockr.fsui)
      webshot2::appshot(
        app = temp_dir,
        file = file.path(OUTPUT_DIR, filename),
        vwidth = SCREENSHOT_WIDTH,
        vheight = SCREENSHOT_HEIGHT,
        delay = 8 # Wait for blockr.md components to load
      )

      # Cleanup
      unlink(temp_dir, recursive = TRUE)

      cat(sprintf("✓ %s created\n", filename))
    },
    error = function(e) {
      cat(sprintf("✗ Failed to create %s: %s\n", filename, e$message))
    }
  )
}

# Generate the README example screenshot
create_md_screenshot("md-board-example.png")

cat("Screenshot generation complete!\n")
cat(sprintf("Screenshot saved to: %s/\n", OUTPUT_DIR))