<#
.SYNOPSIS
    Gets the reason a job finished
.DESCRIPTION
    Gets the `done_reason` from an Ollama Job.

    This indicates why the job was completed.
#>
if ($this.Output[-1].done) {
    $this.Output[-1].done_reason
}