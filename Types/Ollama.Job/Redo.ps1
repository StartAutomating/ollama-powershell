<#
.SYNOPSIS
    Redo Ollama Job
.DESCRIPTION
    Repeats a prompt to an Ollama Job.  
    
    Since LLMs use randomness, this will result in a different reply, unless the seed has been set.
#>
param()

if (-not $this.Input.Model){
    Write-Error "No model name, cannot redo"
    return
}

if ($this.Input.prompt) {
    Get-Ollama -ModelName $this.Input.Model -Prompt $this.Input.prompt -AsJob
}
elseif ($this.input.messages) {
    Get-Ollama -ModelName $this.Input.Model -Message $this.Input.messages -AsJob
}

