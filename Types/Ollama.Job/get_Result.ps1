<#
.SYNOPSIS
    Gets Ollama Job Results
.DESCRIPTION
    Gets the result of an Ollama Job.

    If JSON was outputted, will return an object.
    
    Otherwise, will return the response as text.
#>
if (-not $this.Output.Count) { return }

$allText = @(foreach ($output in $this.Output[0..
    ($this.Output.Count -1)
]) {
    if ($output.Response) {
        $output.Response
    } elseif ($output.message -and 
        $output.message.role -match 'assistant') {
        $output.message.content
    }
})

$allText = $allText -join ''

if ($allText -match '^[\s\r\n]{0,}[\{\["]') {
    ConvertFrom-Json -InputObject $allText
} else {
    $allText
}


