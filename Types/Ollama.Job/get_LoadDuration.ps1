<#
.SYNOPSIS
    Gets the Load Duration
.DESCRIPTION
    Gets the time spent loading the model
#>
[OutputType([timespan])]
param()
if ($this.Output[-1].load_duration) {
    [TimeSpan]::FromMilliseconds(
        $this.Output[-1].load_duration * 0.000001
    )    
}

