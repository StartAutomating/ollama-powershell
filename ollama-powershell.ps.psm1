$commandsPath = Join-Path $PSScriptRoot Commands
[include('*-*')]$commandsPath

$myModule = $MyInvocation.MyCommand.ScriptBlock.Module
$ExecutionContext.SessionState.PSVariable.Set($myModule.Name, $myModule)
$myModule.pstypenames.insert(0, $myModule.Name)

New-PSDrive -Name $MyModule.Name -PSProvider FileSystem -Scope Global -Root $PSScriptRoot -ErrorAction Ignore

if ($home) {
    $MyModuleProfileDirectory = Join-Path ([Environment]::GetFolderPath("LocalApplicationData")) $MyModule.Name
    if (-not (Test-Path $MyModuleProfileDirectory)) {
        $null = New-Item -ItemType Directory -Path $MyModuleProfileDirectory -Force
    }
    New-PSDrive -Name "My$($MyModule.Name)" -PSProvider FileSystem -Scope Global -Root $MyModuleProfileDirectory -ErrorAction Ignore
}

# Set a script variable of this, set to the module
# (so all scripts in this scope default to the correct `$this`)
$script:this = $myModule

#region Custom
$ollamaApplication = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ollama','Application')
if (-not $ollamaApplication) {
    Write-Warning "Ollama is not installed or in the path. Please install it from https://ollama.com/download"
} else {
    $isOllamaRunning = Get-Process -Name ollama -ErrorAction Ignore
    if (-not $isOllamaRunning) {
        $ollamaServer = Start-ThreadJob -Name "ollama serve" -ScriptBlock { ollama serve }        
    }
    $script:OllamaModels = Get-Ollama -ListModel
    foreach ($modelInfo in $script:OllamaModels) {
        $ExecutionContext.SessionState.PSVariable.Set("alias:$($modelInfo.Name -replace '\:latest$')", 'Get-Ollama')
    }
}
#endregion Custom

Export-ModuleMember -Alias * -Function * -Variable $myModule.Name

