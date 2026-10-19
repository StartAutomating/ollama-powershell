if ($this.IO.StringBuilder){
@(
if ($this.Input.prompt) {
    foreach ($line in $this.Input.prompt -split '\[r\n|\n]') {
        "> $($line)"
    }
}
"$($this.IO.StringBuilder)"
if ($this.Error.Count) {
    "~~~"
    $this.Error.Exception.Message
    "~~~"
}
) -join [Environment]::NewLine
    
} else {
    return ($this | Receive-Job -Keep 2>&1 | Out-String)
}