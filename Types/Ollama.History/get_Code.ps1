<#
.SYNOPSIS
    Gets Code Blocks
.DESCRIPTION
    Gets Code Blocks returned from an Ollama Job.
.NOTES
    This will return a dictionary of code blocks, grouped by language.
#>
[OutputType([Collections.IDictionary])]
param()

$codeBlockPattern = 
    [Regex]::new(
        '
            (?>
                (?<FenceChar>[`\~]){3}    # Code fences start with tildas or backticks, repeated at least 3 times
            (?<Language>                  # Match a specific language
            .+?(?=[\r\n])
            )?
            [\s-[\r\n]]{0,}               # Match but do not capture initial whitespace.
            (?<Code>                      # Capture the <Code> block
                (?:.|\s){0,}?             # This is anything until
                (?=\z|\k<FenceChar>{3})   # the end of the string or the same matching fence chars
            )
            (?>\z|\k<FenceChar>{3})
            )
        ', 
        'IgnoreCase,IgnorePatternWhitespace,Singleline'
    )

$codeBlocks = [Ordered]@{}
foreach ($message in $this.ChatLog) {
    if ($message.role -ne 'assistant') { continue }
    foreach ($match in $codeBlockPattern.Matches($message.content)) {
        $language = $match.Groups['Language'].Value
        if ($codeBlocks["$language"]) {
            $codeBlocks["$language"] = @($codeBlocks["$language"]) + $match.Groups['Code'].Value
        } else {
            $codeBlocks["$language"] = $match.Groups['Code'].Value
        }
        #$match        
    }
}
return $codeBlocks
