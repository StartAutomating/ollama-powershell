if ($this.IO.StringBuilder){
    "$($this.IO.StringBuilder)"
} else {
    return ($this | Receive-Job -Keep | Out-String)
}