Write-FormatView -TypeName Ollama.Model -Property Model, Modified_At, Size -VirtualProperty @{
    Size = {
        if ($_.Size -gt 1GB) {
            '{0:N2} gb' -f ($_.Size / 1GB)
        } elseif ($_.Size -gt 1MB) {
            '{0:N2} mb' -f ($_.Size / 1MB)
        } elseif ($_.Size -gt 1KB) {
            '{0:N2} kb' -f ($_.Size / 1KB)
        } elseif ($_.Size) {
            '{0:N2} b' -f $_.Size
        }
    }
}
