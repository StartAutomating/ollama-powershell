function Get-Ollama {
    <#
    .SYNOPSIS
        Gets Ollama models and responses.
    .DESCRIPTION
        Gets [Ollama](https://ollama.com/) models and responses.
        
        This wraps the [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md) in PowerShell.

        This allows you to ask any number of AI models questions and get responses.            
    .EXAMPLE
        Get-Ollama -Model "llama3.2" -Prompt "What is the meaning of life, the universe, and everything?"
    .EXAMPLE
        Get-Ollama -Model "phi4" -Prompt "Write me a limerick"
    .EXAMPLE
        # Pull down a model from the Ollama hub.  Please enjoy the progress bars.
        Get-Ollama -Model "tinyllama" -Pull
    .EXAMPLE
        Get-Ollama -Model "llama3.2" -Prompt "Ollama is 22 years old and is busy saving the world. Respond using JSON" -Format ([Ordered]@{
            type = 'object'
            properties = [Ordered]@{
                age = @{type="integer"}
                available = @{type="boolean"}
                job = @{type="string"}
            }
            required = @("age","available")
        }) -NoStream
    .LINK
        https://github.com/ollama/ollama/blob/main/docs/api.md
    #>
    [CmdletBinding(PositionalBinding=$false, DefaultParameterSetName='cli',SupportsShouldProcess)]    
    param(
    # Any arguments to ollama.
    # This allows you to use Get-Ollama as a proxy for the ollama CLI.
    # This is the default parameter set.
    [Parameter(ParameterSetName='cli',ValueFromRemainingArguments)]
    [PSObject[]]
    $ArgumentList,

    # Any input object.
    [Parameter(ValueFromPipeline)]
    [PSObject]
    $InputObject,

    # If set, will list the currently loaded models
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/tags')]
    [Alias('ListModels')]
    [switch]
    $ListModel,

    # If set, will get the ollama version.
    [Parameter(Mandatory,ParameterSetName='/version')]
    [switch]
    $Version,

    # The name of the language model.
    # If this is not provided, it will be set to the last model used.
    # If no last model was used, it will be set to `llama3.2`
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/show')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/pull')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/create')]
    [Alias('Model','LanguageModel')]
    [string]
    $ModelName,

    # If set, will not stream the response
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/pull')]
    [Alias('NoStreaming')]
    [switch]
    $NoStream,

    # Any options to ollama.  These are used in the `/generate` and `/chat` endpoints.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/embeddings')]
    [Alias('Options')]
    [PSObject]
    $Option = [Ordered]@{},

    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/embeddings')]
    [int]
    $Seed,

    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/embeddings')]
    [int]
    $Temperature,
    

    # When creating a new model, this is the name of the base model
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/create')]
    [string]
    $From,

    # The prompt to send to the model.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName='/embeddings')]
    [string]
    $Prompt,

    # The object or system prompt used to create a new model.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName='/create')]
    [PSObject]
    $Create,

    # One or more messages to send to the model.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Alias('Messages','Chat','ChatHistory')]
    [PSObject[]]
    $Message,

    # If set, will pull a model from the Ollama hub
    [Parameter(Mandatory,ParameterSetName='/pull')]
    [switch]
    $Pull,

    # If set, will get the embedding for a prompt
    [Parameter(Mandatory,ParameterSetName='/embeddings')]
    [Alias('Embeddings')]
    [switch]
    $Embedding,

    # The format for responses.
    # This should be a JSON schema.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/chat')]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/generate')]
    [Alias('ObjectFormat','Schema')]
    [PSObject]
    $Format,

    # If set, will list the running models
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='/ps')]
    [Alias('ListProcesses','GetProcesses','RunningModels')]
    [switch]
    $RunningModel,

    # The url to the Ollama API.
    [Parameter(ValueFromPipelineByPropertyName)]
    [uri]
    $OllamaApi = "http://$([IPAddress]::Loopback):11434/api"
    )

    begin {        
        filter StreamResponse {
            $in = $_
            $initalProperties = [Ordered]@{}
            $typenames = @(foreach ($arg in $args) { 
                if ($arg -is [string]) { $arg}
                if ($arg -is [Collections.IDictionary]) {
                    try {
                        $initalProperties += $arg
                    } catch {
                        foreach ($kv in $arg.GetEnumerator()) {
                            $initalProperties[$kv.Key] = $kv.Value
                        }
                    }
                }
            })
            $in.TypeName = $typenames
            $jobName = "$($in.uri)"
            $in.MainRunspace = [runspace]::DefaultRunspace
            foreach ($kv in $initalProperties.GetEnumerator()) {
                $in[$kv.Key] = $kv.Value
            }
            $startedThreadJob = Start-ThreadJob -ScriptBlock {
                param([Collections.IDictionary]$io)
                foreach ($ioKeyValue in $io.GetEnumerator()) {
                    $ExecutionContext.SessionState.PSVariable.Set($ioKeyValue.Key,$ioKeyValue.Value)
                }                
                $io.StringBuilder = [Text.StringBuilder]::new()
                $in = $io
                $webRequest = [net.httpwebrequest]::Create($in.Uri)
                if ($in.Method) {
                    $webRequest.Method = $in.Method
                }
                if ($in.body) {
                    $bytes = $OutputEncoding.GetBytes($in.body)
                    $webRequest.GetRequestStream().Write(
                        $bytes, 0, $bytes.Length
                    )
                }                
                $webResponse = $webRequest.GetResponse()
                if (-not $webResponse) {
                    return
                }
                $responseStream = $webResponse.GetResponseStream()
                $responseStreamReader = [IO.StreamReader]::new($responseStream)
                $startTime = [datetime]::Now
                $responseNumber = 0                
                
                while ($readLine = $responseStreamReader.ReadLine()) {
                    $streamingResponse = $readLine | ConvertFrom-Json
                    foreach (
                        $thingToAppend in $streamingResponse.error,
                            $streamingResponse.message.content,
                            $streamingResponse.response
                    ) {
                        if ($thingToAppend) {
                            $null = $io.StringBuilder.Append($thingToAppend)
                        }
                    }                    
                    $streamingResponse.pstypenames.clear()
                    foreach ($typename in $typenames) {
                        $streamingResponse.pstypenames.add($typename)
                    }
                    if ($Prompt -and -not $streamingResponse.Prompt) {
                        $streamingResponse.psobject.properties.add(
                            [psnoteproperty]::new('Prompt',$Prompt)
                        )
                    }
                    $streamingResponse.psobject.properties.add(
                        [psnoteproperty]::new('ResponseNumber',$responseNumber)
                    )
                                                            
                    $streamingResponse
                    $responseNumber++
                }
            } -ArgumentList $in -Name $jobName
            $startedThreadJob.psobject.properties.add([psnoteproperty]::new('IO',$in))
            $startedThreadJob.pstypenames.add('Ollama.Job')
            $startedThreadJob
        }

        filter WaitAndSummarize {
            $inJob = $_
            $typenames = @($args)
            if ($inJob -isnot [Management.Automation.Job]) {
                return
            }
            
            $progressSplat = [Ordered]@{Id = $inJob.Id}
            while ($inJob.JobStateInfo.State -eq 'NotStarted') {
                Start-Sleep -Milliseconds (Get-Random -Maximum 100 -Minimum 10)
            }

            $lastLength = 0

            while ("$($inJob.JobStateInfo.State)" -and $inJob.JobStateInfo.State -notin 'Completed','Failed') {
                $resultsSoFar = @($inJob | Receive-Job -Keep)                
                if ($inJob.IO.StringBuilder.Length) {
                    $progressSplat.Activity = "$(
                        if ($Prompt) {
                            $prompt
                        } elseif ($chat -and $chat[-1] -is [string]) {
                            $chat[-1]
                        } elseif ($chat -and $chat[-1].content) {
                            $chat[-1].content
                        }
                    ) "
                    $progressCharWidth = if ($Host.UI.RawUI.BufferSize.Width) { $Host.UI.RawUI.BufferSize.Width / 2 } else { 60 }
                    $progressSplat.Status = "$(
                        $inJob.IO.StringBuilder.ToString().Substring(
                            [Math]::Max(
                                0,
                                $inJob.IO.StringBuilder.Length - $progressCharWidth
                            )
                        ) -replace '[\s\n\r]', ' '
                    )"
                    Write-Progress @progressSplat
                    $lastLength = $inJob.IO.StringBuilder.Length
                }
                
                if ($resultsSoFar.total -and $resultsSoFar.completed) {
                    for ($lastIndex = $resultsSoFar.Count - 1; $lastIndex -ge 0; $lastIndex--) {
                        if ($resultsSoFar[$lastIndex].completed) {
                            $gbDown = [Math]::Round($resultsSoFar[$lastIndex].completed / 1GB, 2)
                            $gbTotal = [Math]::Round($resultsSoFar[$lastIndex].total / 1GB, 2)
                            $progressSplat.Activity = "$($resultsSoFar[$lastIndex].status) "                            
                            $progressSplat.PercentComplete = [Math]::Round(
                                    $resultsSoFar[$lastIndex].completed * 100 / $resultsSoFar[$lastIndex].total,
                                    2
                            )
                            $progressSplat.Status = "$($modelName) [${gbDown}gb / ${gbTotal}gb] $($progressSplat.PercentComplete)%"
                            Write-Progress @progressSplat
                            break
                        }
                    }
                    
                }
                Start-Sleep -Milliseconds (Get-Random -Maximum 1kb -Minimum .25kb)
            }
            $progressSplat.Activity = 'Completed!'
            $progressSplat.Status = 'Done!'
            Write-Progress @progressSplat -Activity 'Waiting for Completion' -Status 'all done' -Completed
                        
            foreach ($typename in $typenames) {
                $inJob.pstypenames.insert(0,$typename)
            }

            if ($originalConsolePosition) {
                [console]::Write("`e[$($originalConsolePosition.Item2);$($originalConsolePosition.Item1)H")
                $inJob
            } else {
                $inJob
            }

            
        }

        $ollamaCli = $ExecutionContext.SessionState.InvokeCommand.GetCommand('ollama','Application')
        $nonPipelineParameters = [Ordered]@{} + $PSBoundParameters
    }

    process {
        # Derive the URL from the parameter set
        $parameterSet = $PSCmdlet.ParameterSetName
        $in = $_
        if ($in.pstypenames -contains 'Ollama.Model') {
            if ($parameterSet -eq 'cli') {
                $parameterSet = '/show'
            }
            if (-not $nonPipelineParameters['ModelName']) {
                if ($in.Model) {
                    $PSBoundParameters['ModelName'] = $modelName = $in.Model
                } elseif ($in.ModelName) {
                    $PSBoundParameters['ModelName'] = $modelName = $in.ModelName
                }                
            }
        }
        $invokeSplat = [Ordered]@{
            Uri = $OllamaApi, ($parameterSet -replace '^/') -join '/'
        }
        
        Write-Verbose "$($invokeSplat.Uri)"

        

        # Determine the model name.
        # This won't _always_ be important, but in most scenarios it is.
        $modelName =
            # If we had not provided a model name parameter 
            if (-not $psBoundParameters['ModelName']) {
                # default to the last model name used
                if ($script:LastOllamaModelName) {
                    $script:LastOllamaModelName
                } else {
                    # If there is no last model name, default to `llama3.2`
                    'llama3.2'
                }
            } else {
                # If there was already a model name provided, use it.
                $ModelName

                
            }

        if ($PSBoundParameters['Format']) {
            if ($format -is [Collections.IList]) {
                $requiredNames = @()
                $FixedFormat = [Ordered]@{
                    type = 'object'
                    properties = [Ordered]@{}
                }
                foreach ($formatProperty in $format) {
                    if ($formatProperty -is [string]) {
                        $fixedFormat.properties[$formatProperty] = @{type='string'}
                        $requiredNames+= $formatProperty
                    } elseif ($formatProperty -is [Collections.IDictionary]) {
                        foreach ($formatKeyValue in $formatProperty.GetEnumerator()) {
                            $fixedFormat.properties[$formatKeyValue.Key] = @{type=$formatKeyValue.Value}
                            $requiredNames+= $formatKeyValue.Key
                        }
                    }                    
                }
                $FixedFormat.required = $requiredNames
                $format = $FixedFormat
            }
        }


        # Switch things based off the parameter set
        switch ($parameterSet) {
            # cli is the only non-restful parameter set
            "cli" {
                if (-not $ollamaCli) {
                    Write-Error 'Missing Ollama'
                    return
                }
                if ($MyInvocation.InvocationName -ne $MyInvocation.MyCommand.Name) {
                    $argumentList = @("run", $MyInvocation.InvocationName) + $argumentList
                }
                if ($Format -and -not ($ArgumentList -contains '--format')) {
                    $argumentList += @("--format", $Format)
                }
                & $ollamaCli @ArgumentList
            }
            {
                $Seed -or $Temperature
            } {
                if ($Seed) {
                    # If we have a seed, set the appropriate option
                    $Option['seed'] = $Seed
                }
                
                if ($Temperature) {
                    # If we have a temperature, set the appropriate option
                    $Option['temperature'] = $Temperature
                }
            }
            # version is the easiest parameter set
            "/version" {
                # If `-WhatIf` was passed, return the splat.
                if ($WhatIfPreference) { return $invokeSplat }
                # If -Confirm was passed and the user does not want to continue, return.
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri)) { return }

                Invoke-RestMethod @invokeSplat
            }
            # /tags and /ps are functionally the same
            { $_ -in '/tags','/ps' } {
                # If `-WhatIf` was passed, return the splat.
                if ($WhatIfPreference) { return $invokeSplat }
                # If -Confirm was passed and the user does not want to continue, return.
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri)) { return }

                # Get the .models property from any rest method call
                foreach ($modelInfo in @(@(Invoke-RestMethod @invokeSplat).models)) {
                    # (keep moving past any nulls)
                    if (-not $modelInfo) { continue }
                    # Clear our typenames
                    $modelInfo.pstypenames.clear()
                    # If we're in the `/ps` parameter set, add `Ollama.Model.Running`
                    if ($parameterSet -eq '/ps') {
                        $modelInfo.pstypenames.add("Ollama.Model.Running")
                    }
                    # always add `Ollama.Model`
                    $modelInfo.pstypenames.add('Ollama.Model')
                    # and emit the model information.
                    $modelInfo                    
                }
            }
            # /show gets us model details
            '/show' {                
                $invokeSplat.Method = 'POST'
                $invokeSplat.Body = ConvertTo-Json -InputObject @{model=$ModelName;verbose= $VerbosePreference -eq 'continue'}
                # If `-WhatIf` was passed, return the splat.
                if ($WhatIfPreference) { return $invokeSplat }
                # If -Confirm was passed and the user does not want to continue, return.
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }
                # Get the model information.
                $modelInfo = Invoke-RestMethod @invokeSplat
                # assuming we got something back
                if ($modelInfo) {
                    # Clear our typenames
                    $modelInfo.pstypenames.clear()
                    # And decorate the model information
                    $modelInfo.pstypenames.add('Ollama.Model.Info')
                    $modelInfo.pstypenames.add('Ollama.Model')
                    if (-not $modelInfo.model) {
                        $modelInfo.psobject.Properties.Add(
                            [psnoteproperty]::new('Model',$ModelName),
                            $true
                        )
                    }
                    $modelInfo
                }
            }
            # /chat describes a conversation with a model, and is a bit more complex
            '/chat' {                
                $invokeSplat.Method = 'POST'                
                $invokeSplat.Body = [Ordered]@{                    
                    model = $ModelName                    
                    messages = # since we want to be easier than the raw API
                        # walk over each message and make it more system friendly.
                        @(foreach ($msg in $message) {
                            if ($msg -is [string]) {
                                # If it was a string, make it a `user` message
                                @{role='user';content=$msg}
                            } else {
                                # otherwise, keep the message as-is.
                                $msg
                            }
                        })
                }                
                
                # If we want output in a particular format
                if ($Format) {
                    # add it to the body
                    $invokeSplat.Body.format = $Format
                }
                
                # If we do not want to stream the response
                if ($NoStream) {
                    # say so now.
                    $invokeSplat.Body.stream = $false
                }                

                # If we have any additional options
                if ($Option) {
                    # add them to the body.
                    $invokeSplat.Body.options = $Option
                }
                
                # Convert the body to JSON.
                $invokeSplat.Body = $invokeSplat.Body | ConvertTo-Json -Depth 10
                # If `-WhatIf` was passed, return the splat.
                if ($WhatIfPreference) { return $invokeSplat }
                # If -Confirm was passed and the user does not want to continue, return.
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }

                # If we're not streaming
                if ($NoStream) {
                    # we can use Invoke-RestMethod
                    $noStreamingResponse = Invoke-RestMethod @invokeSplat
                    # and simply decorate our return.
                    $noStreamingResponse.pstypenames.clear()
                    $noStreamingResponse.pstypenames.add('Ollama.Chat')                    
                    $noStreamingResponse
                } else {
                    # Otherwise, we need to stream the response
                    $InvokeSplat |
                        # each returned message will be an `Ollama.Chat.Response`
                        StreamResponse 'Ollama.Chat.Response' |
                        # and we will wait for the job to finish and call it both an `Ollama.Chat` and an `Ollama.Job`
                        WaitAndSummarize 'Ollama.Chat' 'Ollama.Job'
                }
            }
            # /pull will download a model from the Ollama hub            
            '/pull' {
                $invokeSplat.Method = 'POST'
                $invokeSplat.Body = [Ordered]@{model=$ModelName}

                # We can technically pull without streaming, but, why would you want to?
                if ($NoStream) {
                    $invokeSplat.Body.stream = $false
                }

                $invokeSplat.Body = $invokeSplat.Body | ConvertTo-Json -Depth 20 
                # If `-WhatIf` was passed, return the splat.
                if ($WhatIfPreference) { return $invokeSplat }
                # If -Confirm was passed and the user does not want to continue, return.
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }

                # If we are not streaming
                if ($NoStream) {
                    # then try to Invoke-RestMethod
                    # (for a pull, there's a decent chance this would time out)
                    $noStreamingResponse = Invoke-RestMethod @invokeSplat
                    $noStreamingResponse.pstypenames.clear()
                    $noStreamingResponse.pstypenames.add('Ollama.Pull')
                    $noStreamingResponse
                } else {
                    # Otherwise, we need to stream the response
                    $InvokeSplat | 
                        # each returned message will be an `Ollama.Pull.Response`
                        StreamResponse 'Ollama.Pull.Response' |
                        # and we will wait for the job to finish and call it both an `Ollama.Pull` and an `Ollama.Job`
                        WaitAndSummarize 'Ollama.Pull' 'Ollama.Job'
                }
            }
            '/create' {
                $invokeSplat.Method = 'POST'
                $invokeSplat.Body = [Ordered]@{}
                if ($Create -is [string]) {
                    $invokeSplat.Body.system = $create
                } else {
                    if ($create -is [Collections.IDictionary]) {
                        foreach ($property in $create.psobject.properties) {
                            $invokeSplat.Body[$property.Name] = $property.Value
                        }
                    } else {
                        foreach ($property in $create.psobject.properties) {
                            $invokeSplat.Body[$property.Name] = $property.Value
                        }
                    }                                        
                }
                if (-not $body.model) {
                    $invokeSplat.Body.model = $ModelName
                }
                if ($From) {
                    $invokeSplat.Body.from = $From
                }

                $invokeSplat.Body = $invokeSplat.Body | ConvertTo-Json -Depth 20 
                if ($WhatIfPreference) {
                    return $invokeSplat
                }
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }
                    
                if ($NoStream) {
                    $noStreamingResponse = Invoke-RestMethod @invokeSplat
                    $noStreamingResponse.pstypenames.clear()
                    $noStreamingResponse.pstypenames.add('Ollama.Create')
                    $noStreamingResponse
                } else {
                    $InvokeSplat |
                        StreamResponse 'Ollama.Create.Response' |
                        WaitAndSummarize 'Ollama.Create'
                }                                
            }
            '/embeddings' {
                $invokeSplat.Method = 'POST'
                $invokeSplat.Body = [Ordered]@{
                    model=$ModelName
                    prompt=$Prompt                    
                }
                
                if ($Option) {
                    $invokeSplat.Body.options = $Option
                }
                $invokeSplat.Body = $invokeSplat.Body | ConvertTo-Json -Depth 20
                if ($WhatIfPreference) {
                    return $invokeSplat
                }
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }
                Invoke-RestMethod @invokeSplat
            }
            '/generate' {
                $invokeSplat.Method = 'POST'
                $invokeSplat.Body = [Ordered]@{
                    model=$ModelName
                    prompt=$Prompt                    
                }
                
                if ($NoStream) {
                    $invokeSplat.Body.stream = $false
                }                

                if ($Option) {
                    $invokeSplat.Body.options = $Option
                }

                if ($Format) {
                    $invokeSplat.Body.format = $Format
                }
                                
                $invokeSplat.Body = $invokeSplat.Body | ConvertTo-Json -Depth 20 
                if ($WhatIfPreference) {
                    return $invokeSplat
                }
                if (-not $PSCmdlet.ShouldProcess($invokeSplat.Uri, $invokeSplat.Body -join [Environment]::NewLine)) { return }
                    
                if ($NoStream) {
                    $noStreamingResponse = Invoke-RestMethod @invokeSplat
                    $noStreamingResponse.pstypenames.clear()
                    $noStreamingResponse.pstypenames.add('Ollama.Prompt')
                    $noStreamingResponse
                } else {
                    $InvokeSplat | 
                        StreamResponse 'Ollama.Prompt.Response' |
                        WaitAndSummarize 'Ollama.Prompt' 'Ollama.Job'
                }
            }
        }
    }
}
