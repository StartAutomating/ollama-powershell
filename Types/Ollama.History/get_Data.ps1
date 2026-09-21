<#
.SYNOPSIS
    Ollama History Data
.DESCRIPTION
    Reads an Ollama History file and returns the data within it.
.NOTES
    Caches the data read to avoid repeated reads from disk.
#>
param()
if ($this.'#Data') {
    return $this.'#Data'
}

$this | Add-Member NoteProperty '#Data' (
    Get-Content $this.Fullname -raw | 
        ConvertFrom-Json
) -Force

return $this.'#Data'
