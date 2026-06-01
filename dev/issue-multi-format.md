## Summary

Extend the markdown builder to emit **PDF** and **HTML** in addition to the existing PPTX output. Format becomes an end-user-selectable control on the md block; theming for each format is plugged in via `options()` the same way `blockr.md_template` already works for pptx.

DOCX is out of scope for now.

## Motivation

Today blockr.md only outputs PPTX. Users (mostly clinical/topline workflows) regularly ask for PDF — standard distribution format for reports. HTML is essentially free from pandoc once the dispatch layer exists and may sidestep a chunk of the PDF/LaTeX headache.

Nicolas is owner of blockr.md but bandwidth-constrained, so we wanted a tight spec + thin prototype on a branch that he can review, push back on, or take over. The spec is at [`blockr.design/open/md-multi-format/`](../../../blockr.design/tree/main/open/md-multi-format). The prototype is on branch `feat/multi-format` (commit f00f865).

## Design (short version)

- **One render block, format picker added.** New `selectInput` with `pptx` / `pdf` / `html`. Existing template selector becomes format-aware via `renderUI`. Single Download button; filename + MIME derive from the selected format.
- **Engine: pandoc via `rmarkdown::pandoc_convert`.** No new system dependency on Connect — pandoc is already there. Quarto was considered and rejected because we can't assume a working quarto install on locked-down corporate Connect.
- **Per-format theming via `options()`**, mirroring the existing `blockr.md_template` (pptx) pattern:
  - `blockr.md_template_pdf`  — named char vector
  - `blockr.md_template_html` — named char vector
  - `blockr.md_pandoc_args_{pptx,pdf,html}` — extra pandoc args (e.g. `--pdf-engine=xelatex`)
  Downstream apps (blockr.topline-style) override these to inject branded templates.
- **PDF fallback.** At session start, probe for `pdflatex`/`xelatex`/`tinytex::is_tinytex()`. If unavailable, `pdf` is hidden from the format picker and a muted note explains why. PPTX and HTML stay selectable. No silent format fallback.
- **No bundled tex/html templates.** Empty default path = pandoc uses its own built-in template, which always matches the installed pandoc version. (Initial prototype bundled `pandoc -D latex` output, which caused `! Undefined control sequence \pandocbounded` on machines with pandoc ≥ 3.2 — that's exactly the version-skew we want to avoid.) PPTX still ships its bundled reference-doc, because pptx reference-docs don't have this problem.
- **Cross-format table parity is a non-goal.** `flextable` stays pptx-flavored. For PDF/HTML the builder picks an appropriate table block (`gt` is the expected one). The render block doesn't try to translate.

## Surface changes

- `R/templates.R` — `get_template_choices(format)`, `default_template(format)`, `get_template_opts(format)`, `get_pandoc_args(format)`, `pdf_available()`, `available_formats()`.
- `R/md-render-format.R` — new, single `render_format(ast, format, template, output)` dispatcher.
- `R/md-ui.R` — format `selectInput`, reactive template selector, reactive file-input `accept`, PDF-unavailable note.
- `R/md-server.R` — `output$dl` (renamed from `dl_ppt`), format-aware filename, calls `render_format`.
- `DESCRIPTION` — `tinytex` added to `Suggests`.
- `dev/app.R`, `dev/check-pdf.R` — runnable example + PDF-availability diagnostic.

## What works

- HTML and PDF render through the full Shiny pipeline (table + plot blocks embedded), verified on macOS + container.
- PPTX path is regression-free.
- BMS/customer-template override works the same way as for pptx today.

## Open questions for review

- Default format. Currently `pptx` to preserve current behavior; revisit once PDF stabilizes.
- Placement of the format picker (currently inside the block UI next to the template picker; could move to dock chrome).
- Custom-template upload behavior when the user switches formats mid-session. Current sketch lets the upload stick across format changes; clearing might be cleaner.

## Status

- Spec: [`blockr.design/open/md-multi-format/`](../../../blockr.design/tree/main/open/md-multi-format) (4 phases).
- Prototype: branch `feat/multi-format`, commit f00f865, not pushed yet.
- Happy to hand off to Nicolas — flagging this issue so it's tracked rather than living in a branch nobody sees.
