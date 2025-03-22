@{
    RootModule = 'ollama-powershell.psm1'
    ModuleVersion = '0.0.1'
    GUID = 'e9b68160-0f70-4821-86c5-64ddb66e841c'
    Description = 'Play with AI in PowerShell'
    Author = 'James Brundage'
    CompanyName = 'Start-Automating'
    Copyright = '2025 Start-Automating'
    TypesToProcess = @('ollama-powershell.types.ps1xml')
    FormatsToProcess = @('ollama-powershell.format.ps1xml')
    PrivateData = @{
        PSData = @{            
            Tags = @('AI','ollama', 'PowerShell', 'LLM')
            LicenseURI = 'https://github.com/StartAutomating/ollama-powershell/blob/main/LICENSE'
            ProjectURI = 'https://github.com/StartAutomating/ollama-powershell'
            ReleaseNotes = @'
Initial release of ollama-powershell!

Use ollama-powershell to interact with the Ollama API and run LLM models locally.

* `Get-Ollama` wraps the Ollama CLI and Ollama rest API
* `Remove-Ollama` removes models from your local system
'@
        }
    }
}

