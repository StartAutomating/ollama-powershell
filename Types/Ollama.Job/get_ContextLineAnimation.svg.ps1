<#
.SYNOPSIS
    Gets a Job's Context
.DESCRIPTION
    Gets's a Job's Context.

    When a job has completed, that last object will contain a `context`.

    This is a series of numbers that can be crunched or visualized.

    This property returns that last object's context property, if one is present.
#>
param()

$thisContext = $this.Context -as [double[]]

[xml]"
<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'>
<polyline points='$thisContext' stroke='currentColor' fill='transparent'>
    <animate attributeName='points' values='$thisContext;$(
        foreach ($point in $thisContext) {
            $point + (Get-Random -Maximum 16 -Minimum -16)
        }
    );$thisContext' dur='4.2s' repeatCount='indefinite' />
</polyline>
</svg>
"




