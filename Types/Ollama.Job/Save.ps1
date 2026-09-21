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
        $this.PSBeginTime.ToUniversalTime().ToString('o').Replace(':','_'),
            $this.Input.Model -join 
                '-'

    $path =
        [Environment]::GetFolderPath("ApplicationData"), 
            "ollama-powershell",
                $path -join
                    '/'
}

$path = $path -replace '\.json$' -replace '$', '.json'

if (-not $path) { return }

$startTime = $this.PSBeginTime
$endTime = if ($this.PSEndTime -is [DateTime]) {
    $this.PSEndTime -is [DateTime]
} elseif ($this.Output[-1].total_duration) {
    $startTime += [TimeSpan]::FromMilliseconds(
        $this.Output[-1].total_duration * 0.000001
    )
} else {
    [DateTime]::Now
}

New-Item -ItemType File -Path $path -Value (
    [Ordered]@{
        modelName = $this.Input.ModelName
        start = $this.PSBeginTime
        end = $endTime
        duration = "$(if ($endTime) {
            $endTime - $startTime
        })"        
        input = $this.Input
        chatlog = $this.Chatlog
        summary = $this.Output[-1]
        url = $this.Name
    } | 
        ConvertTo-Json -Depth 100
) -Force