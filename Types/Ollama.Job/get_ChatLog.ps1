<#
.SYNOPSIS
    Gets the Chatlog
.DESCRIPTION
    Gets the chatlog for an Ollama Job.

    This returns the messages between the user and the assistant.
#>
if ($this.Input.Prompt) {
    [PSCustomObject]@{
        role = 'user'
        content = $this.Input.Prompt
    }
}
elseif ($this.Input.messages) {
    $this.Input.messages
}

for ($index =0 ; $index -lt $this.Output.Count; $index++) {
    $output = $this.Output[$index]
    $nextIndex = $index;
    $assistantMessage = while (
        ($nextIndex -lt $this.Output.Count) -and
        ($output.response -or $output.message.role)        
    ) {
        if ($output.response) {
            $output.response
        } else {
            $output.message.content
        }
        
        $nextIndex++
        $output = $this.Output[$nextIndex]
    }

    if ($assistantMessage) {
        [PSCustomObject]@{
            role = 'assistant'
            content = $assistantMessage -join ''
        }
        $index = $nextIndex
    }    
}