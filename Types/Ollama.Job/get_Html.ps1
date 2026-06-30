<#
.SYNOPSIS
    Gets Ollama Job output as html
.DESCRIPTION
    Gets Ollama Job output as html.

    Unless the output explicitly starts with a tag,
    this will presume output is markdown.
#>
param()

if (-not $this.ToString.Invoke) { return }

$content = $this.ToString()

if ($content -match '^[\s\r\n]+\<') {
    $content
} else {
    (ConvertFrom-Markdown -InputObject $content).Html
}