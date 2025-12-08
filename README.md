
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
library(blockr)
library(blockr.dag)
library(blockr.md)
library(blockr.ai)

run_app(
  blocks = c(
    a = new_dataset_block("mtcars"),
    b = new_scatter_block("disp", "hp"),
    c = new_llm_insights_block("List the 5 most powerful cars.")
  ),
  links = list(from = c("a", "a"), to = c("b", "c"), input = rep("data", 2)),
  extensions = list(
    dag = new_dag_extension(),
    doc = new_md_extension(
      c(
        "# My title",
        "",
        "## Slide with table",
        "",
        "![](blockr://a)",
        "",
        "## Slide with plot",
        "",
        "![Displacement (cu.in.) vs. gross horsepower](blockr://b)",
        "",
        "## Slide with AI text",
        "",
        "![](blockr://c)",
        "",
        "## Slide with MD text",
        "",
        "Some paragraph text.",
        "",
        "- bullet 1",
        "- bullet 2",
        "",
        "That's it, that's all."
      )
    )
  ),
  layout = list("dag", c("doc", "a", "b", "c"))
)
```
