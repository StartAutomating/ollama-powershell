<#
.SYNOPSIS
    Gets the ollama input
.DESCRIPTION
    Gets the ollama request input body as an object.
#>
if (-not $this.IO.Body) { return }

ConvertFrom-Json -InputObject $this.IO.Body