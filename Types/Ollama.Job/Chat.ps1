<#
.SYNOPSIS
    Chats with an agent
.DESCRIPTION
    Continues an existing chat with an agent.  
    
    This will send the chatlog to Ollama, with any additional new messages
#>
param()

# The new chat is our old chat
$chat = @($this.Chatlog) + @(
    # plus any arguments
    foreach ($arg in $args) {
        # If the argument was a message
        if ($arg.role -and $arg.content) {
            [PSCustomObject]@{role=$arg.role;content=$arg.content}
        } 
        elseif ($arg.role -and $arg.message) {
            [PSCustomObject]@{role=$arg.role;content=$arg.message}
        }
        else {
            [PSCustomObject]@{role='user';content="$arg"}
        }
    }
)


if ($this.ModelName) {
    Get-Ollama -ModelName $this.ModelName -Message $chat -AsJob
}


