<#
.SYNOPSIS
    Gets the Token Duration
.DESCRIPTION
    Gets the time spent evaluating and processing the prompt.
#>
if ($this.eval_duration -and $this.prompt_eval_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.eval_duration * 0.000001
    ) + [TimeSpan]::FromMilliseconds(
        $this.prompt_eval_duration * 0.000001
    )    
}
elseif ($this.eval_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.eval_duration * 0.000001
    )
}