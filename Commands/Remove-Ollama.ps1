function Remove-Ollama {
    <#
    .SYNOPSIS
        Remove a model
    .DESCRIPTION
        Removes an Ollama model.
        
        This is a destructive operation, and will confirm before proceeding.
    .LINK
        https://github.com/ollama/ollama/blob/main/docs/api.md#delete-a-model
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param(
    # The name of the model to remove.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName='/delete')]
    [Alias('Model','LanguageModel')]
    [string]
    $ModelName,

    # The url to the Ollama API.
    [Parameter(ValueFromPipelineByPropertyName)]
    [uri]
    $OllamaApi = "http://$([ipaddress]::Loopback):11434/api"
    )

    process {
        $parameterSet = $PSCmdlet.ParameterSetName
        $invokeSplat = [Ordered]@{
            Uri = $OllamaApi, $parameterSet -join '/' -replace '/{2,}','/' -replace ':/','://'
        }
        Write-Verbose "$($invokeSplat.Uri)"

        switch ($parameterSet) {
            '/delete' {
                $invokeSplat.Method = 'DELETE'
                $invokeSplat.Body = @{model = $ModelName} | ConvertTo-Json
                if ($WhatIfPreference) {
                    return $invokeSplat
                }
                if (-not $PSCmdlet.ShouldProcess("Delete model $modelName")) {
                    return
                }
                Invoke-RestMethod @invokeSplat
            }
        }
    }
}
