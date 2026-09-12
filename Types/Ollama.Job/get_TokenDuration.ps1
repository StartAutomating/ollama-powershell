<#
.SYNOPSIS
    Gets the Token Duration
.DESCRIPTION
    Gets the time spent evaluating and processing the prompt.
#>
if ($this.Output[-1].eval_duration -and $this.Output[-1].prompt_eval_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.Output[-1].eval_duration * 0.000001
    ) + [TimeSpan]::FromMilliseconds(
        $this.Output[-1].prompt_eval_duration * 0.000001
    )    
}
elseif ($this.Output[-1].eval_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.Output[-1].eval_duration * 0.000001
    )
}

