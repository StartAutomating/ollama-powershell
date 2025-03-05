@{
    "runs-on" = "ubuntu-latest"    
    if = '${{ success() }}'
    steps = @(
        @{
            name = 'Check out repository'
            uses = 'actions/checkout@v2'
        }
        @{
            name = 'GitLogger'
            uses = 'GitLogging/GitLoggerAction@main'
            id = 'GitLogger'
        }
        @{
            name = 'Use PSSVG Action'
            uses = 'StartAutomating/PSSVG@main'
            id = 'PSSVG'
        }
        @{
            name = 'Use PipeScript Action'
            uses = 'StartAutomating/PipeScript@main'
            id = 'PipeScript'
        }
        'RunEZOut'
        'RunHelpOut'
        <#,
        @{
            name = 'Use PSJekyll Action'
            uses = 'PowerShellWeb/PSJekyll@main'
            id = 'PSJekyll'
        }#>
        <#@{
            name = 'Run WebSocket (on branch)'
            if   = '${{github.ref_name != ''main''}}'
            uses = './'
            id = 'WebSocketAction'
        },#>
        # 'BuildAndPublishContainer'
    )
}