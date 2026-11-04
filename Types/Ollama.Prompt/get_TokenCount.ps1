<#
.SYNOPSIS
    Gets the token count
.DESCRIPTION
    Gets the total tokens evaluated by the model and the prompt.

    This is the `.eval_count` plus the `.prompt_eval_count`
#>
$this.prompt_eval_count + $this.eval_count