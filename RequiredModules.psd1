@{
    # Set up a mini virtual environment...
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
        }
    }

    invokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    pester                      = 'latest'
    Plaster                     = 'latest'
    Platyps                     = 'latest'
    ModuleBuilder               = '1.0.0'
    ChangelogManagement         = 'latest'
    Sampler                     = 'latest'
    MarkdownLinkCheck           = 'latest'
    'Az.Accounts'               = '1.5.1'
    'Az.Resources'              = '1.3.1'
}
