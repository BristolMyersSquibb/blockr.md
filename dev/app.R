pkgload::load_all("blockr.core")
pkgload::load_all("blockr.dock")
pkgload::load_all("blockr.dag")
pkgload::load_all("blockr.ui")
pkgload::load_all("blockr.md")

library(blockr)

# options(shiny.port = 3838, shiny.host = "0.0.0.0")

run_app(
  blocks = c(
    a = new_dataset_block("mtcars"),
    b = new_scatter_block("disp", "hp")
  ),
  links = list(from = "a", to = "b", input = "data"),
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
        "![Displacement vs. horsepower](blockr://b)",
        ""
      )
    )
  )
)
