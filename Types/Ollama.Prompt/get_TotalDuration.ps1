<#
.SYNOPSIS
    Gets the Total Duration
.DESCRIPTION
    Gets the total duration of a request.

    This should be the combined the LoadDuration and TokenDuration
#>
[OutputType([timespan])]
param()
if ($this.total_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.total_duration * 0.000001
    )    
}
