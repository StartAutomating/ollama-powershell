<#
.SYNOPSIS
    Gets Ollama Prompt Results
.DESCRIPTION
    Gets the result of an Ollama Prompt.

    If JSON was outputted, will return an object.
    
    Otherwise, will return the response as text.
#>
$allText = $this.Response

if ($allText -match '^[\s\r\n]{0,}[\{\["]') {
    ConvertFrom-Json -InputObject $allText
} else {
    $allText
}


