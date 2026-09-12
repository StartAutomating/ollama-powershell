<#
.SYNOPSIS
    Gets the token count
.DESCRIPTION
    Gets the total tokens evaluated by the model and the prompt.

    This is the `.eval_count` plus the `.prompt_eval_count`
#>
param()
if ($this.Output[-1].eval_count) {
    $this.Output[-1].eval_count + 
        $this.Output[-1].prompt_eval_count
}

