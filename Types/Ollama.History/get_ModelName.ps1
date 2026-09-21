<#
.SYNOPSIS
    Gets the Model Name
.DESCRIPTION
    Gets the name of the model used in an Ollama history file.
#>
# If the data has a model name
if ($this.Data.ModelName) {
    # return it
    return $this.Data.ModelName
}
# Otherwise, take the file name,
return $this.Name -replace 
    '[\d\-_T]+' -replace # remove the data portion,
    '\.json$' -replace  # remove the extension,
    '^\p{P}+' -replace # remove any leading punctuation
    '\p{P}+$' #  remove any trailining punctuation
