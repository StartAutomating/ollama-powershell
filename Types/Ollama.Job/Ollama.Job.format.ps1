Write-FormatView -TypeName Ollama.Job -Action {
    $inJob = $_
    if ($injob.StringBuilder.Length) {
        "$($inJob.StringBuilder)"
    } else {
        $jobResults = $_ | Receive-Job -Keep *>&1
        $resultText = @(foreach ($result in $jobResults) {
            if ($result.response) {
                $result.response
            } elseif ($result.message.content) {
                $result.message.content
            }
            elseif ($result.error) {
                if ($PSStyle) {
                    $PSStyle.Formatting.Error
                    $result.error
                    $PSStyle.Reset
                }            
            }
            elseif ($result -is [Management.Automation.ErrorRecord]) {
                $result.Exception.Message
            }       
        }) -join ''
        if ($resultText) {
            $resultText
        } else {
            $jobResults | Out-String
        }
    }    
}
