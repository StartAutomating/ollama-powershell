<#
.SYNOPSIS
    Gets the reason a request finished
.DESCRIPTION
    Gets the `done_reason` from an Ollama request.

    This indicates why it believes the request was completed.
#>
if ($this.done) {
    $this.done_reason
}