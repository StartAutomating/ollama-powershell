<#
.SYNOPSIS
    Gets the Total Duration
.DESCRIPTION
    Gets the total duration of a request.

    This should be the combined the LoadDuration and TokenDuration
#>
[OutputType([timespan])]
param()
if ($this.Output[-1].total_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.Output[-1].total_duration * 0.000001
    )    
}
