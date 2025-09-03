# PowerPoint Templates for blockr.md

This directory contains PowerPoint templates for use with blockr.md document generation.

## Templates

### `pandoc-default.pptx`
The original default reference template that ships with pandoc. This template is guaranteed to work without corruption issues and contains all the required slide layouts that pandoc expects.

## Creating Custom Templates

If you need to use a custom client template, follow these steps to avoid corruption issues:

### Safe Template Creation Process

1. **Start with the default template**:
   ```r
   # Copy the default template to your working directory
   file.copy(
     system.file("templates", "pandoc-default.pptx", package = "blockr.md"),
     "my-custom-template.pptx"
   )
   ```

2. **Open the template in PowerPoint**:
   - Open `my-custom-template.pptx` in PowerPoint
   - Go to **View → Slide Master**

3. **Apply your branding safely**:
   - ✅ Change colors, fonts, and backgrounds
   - ✅ Add logos and graphics
   - ✅ Modify text styles
   - ✅ Adjust placeholder sizes and positions
   - ❌ **DO NOT** delete or rename slide layouts
   - ❌ **DO NOT** remove placeholders entirely

4. **Required Slide Layouts**:
   Your template must contain these layout names:
   - **Title Slide** - for document title slides
   - **Title and Content** - for standard content slides
   - **Section Header** - for section dividers
   - **Two Content** - for two-column slides
   - **Content with Caption** - for slides with images/tables
   - **Comparison** - alternative two-column layout
   - **Blank** - for custom content

5. **Save and test**:
   - Save your template
   - Test with a simple markdown document
   - If PowerPoint shows a "repair" dialog, the template needs adjustment

## Common Issues

### Template Corruption
If PowerPoint shows "PowerPoint found a problem with content" and offers to repair:

- **Cause**: Template was modified incorrectly or synced with Teams/SharePoint
- **Solution**: Start over with the default template and make minimal changes

### Missing Layouts
If pandoc fails with "Could not find shape for content":

- **Cause**: Required slide layouts are missing or renamed
- **Solution**: Ensure all required layouts exist with correct names

### Blank Slides
If slides appear blank:

- **Cause**: Placeholders were deleted or incorrectly positioned
- **Solution**: Compare with default template and restore placeholders

## Best Practices

1. **Always start from the pandoc default template**
2. **Make incremental changes and test frequently**
3. **Never sync templates with cloud services**
4. **Keep backups of working templates**
5. **Test templates with flextable content to ensure compatibility**

## Using Templates in blockr.md

```r
# Use bundled default template
board <- new_md_board(
  pptx_template = system.file("templates", "pandoc-default.pptx", package = "blockr.md")
)

# Use custom template
board <- new_md_board(
  pptx_template = "path/to/my-custom-template.pptx"
)
```