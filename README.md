
<!-- README.md is generated from README.Rmd. Please edit that file -->

# blockr.md

<!-- badges: start -->

<!-- badges: end -->

The extension package blockr.md provides a markdown document builder to
a blockr board.

## Installation

You can install the development version of blockr.md from
[GitHub](https://github.com/BristolMyersSquibb/blockr.md) with:

``` r
# install.packages("pak")
pak::pak("BristolMyersSquibb/blockr.md")
```

## Example

A board with a simple plot block and a document that includes the
corresponding plot can be creates as follows.

``` r
library(blockr.core)
library(blockr.md)

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
      "Some sentence to introduce in a first paragraph to introduce the topic",
      "of my document.",
      "",
      "![block](blockr://b)",
      "",
      "And another sentence in a final paragraph to end my document."
    )
  )
)
```
