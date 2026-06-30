<#
.SYNOPSIS
    Gets Ollama Job output as html
.DESCRIPTION
    Gets Ollama Job output as html.

    Unless the output explicitly starts with a tag,
    this will presume output is markdown.
#>
param()

# Return if this has no tostring method
if (-not $this.ToString.Invoke) { return }

# Get our content
$content = $this.ToString()

# If it starts with a tag
if ($content -match '^[\s\r\n]{0,}\<') {
    $content # output it.
} else {
    # otherwise, convert it from markdown and output the html.
    (ConvertFrom-Markdown -InputObject $content).Html
}