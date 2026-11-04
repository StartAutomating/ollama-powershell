<#
.SYNOPSIS
    Gets a Prompt's Load Duration     
.DESCRIPTION
    Gets the time spent loading an LLM for a given prompt. 
#>
if ($this.load_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.load_duration * 0.000001
    )    
}

