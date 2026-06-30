if ($this.IO.StringBuilder){
@(
if ($this.Input.prompt) {
    foreach ($line in $this.Input.prompt -split '\[r\n|\n]') {
        "> $($line)"
    }
}
"$($this.IO.StringBuilder)"
) -join [Environment]::NewLine
    
} else {
    return ($this | Receive-Job -Keep | Out-String)
}