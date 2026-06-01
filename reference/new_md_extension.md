# MD extension

A markdown extension adds a document builder.

## Usage

``` r
new_md_extension(content = character(), ...)

md_render(x, value, dir = tempdir(), ...)

# S3 method for class 'md_text'
md_render(x, value, dir = tempdir(), ...)

# S3 method for class 'file'
md_render(x, value, dir = tempdir(), ...)

# S3 method for class 'ggplot'
md_render(x, ...)

# S3 method for class 'recordedplot'
md_render(x, value, dir = tempdir(), ..., .is_patchwork = FALSE)

# S3 method for class 'evaluate_evaluation'
md_render(x, ...)

# S3 method for class 'data.frame'
md_render(x, ...)

# S3 method for class 'gt_tbl'
md_render(x, value, dir = tempdir(), ...)

# S3 method for class 'flextable'
md_render(x, ...)
```

## Arguments

- content:

  Initial document

- ...:

  Forwarded to
  [`blockr.dock::new_dock_extension()`](https://bristolmyerssquibb.github.io/blockr.dock/reference/extension.html)

- x:

  Plot

- value:

  Current md block value

- dir:

  Where to place files (like images)

- .is_patchwork:

  Is plot a patchwork plot?
