<#
.SYNOPSIS
    Saves job results
.DESCRIPTION
    Saves the results of an Ollama Job.
#>
param(
# The path used to save the job.
# If the path is not found,
[string]
$Path
)

if (-not $path -and $this.PSBeginTime) {
    $path = 
        $this.Input.Model,
            $this.PSBeginTime.ToUniversalTime().ToString('o').Replace(':','_') -join 
                '-'
}

$path = $path -replace '\.json$' -replace '$', '.json'

if (-not $path) { return }

New-Item -ItemType File -Path $path -Value (
    [Ordered]@{
        start = $this.PSBeginTime
        end = $this.PSEndTime
        duration = "$(if ($this.PSEndTime) {
            $this.PSEndTime - $this.PSBeginTime
        })"
        input = $this.Input
        output = $this | Receive-Job -Keep
        url = $this.Name
    } | 
        ConvertTo-Json -Depth 100
) -Force