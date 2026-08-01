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

# If this is not a job, we can't receive it's results.
if ($this -isnot [Management.Automation.Job]) {
    return
}

if (-not $this.Output.Count) { return }

# Get the last output's context
return $this.Output[-1].Context