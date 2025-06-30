
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
```
