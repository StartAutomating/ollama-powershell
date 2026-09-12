<#
.SYNOPSIS
    Gets the Token Rate
.DESCRIPTION
    Gets the rate tokens were processed in tokens/second.

    This is the token count / token rate
#>
param()
$tokenCount = $this.TokenCount
$tokenDuration = $this.TokenDuration
if ($tokenCount -and $tokenDuration.TotalSeconds) { $tokenCount / $tokenDuration.TotalSeconds }
