@{
    PSDependOptions     = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = ''
        }
    }
    invokeBuild         = 'latest'
    PSScriptAnalyzer    = 'latest'
    pester              = 'latest'
    Plaster             = 'latest'
    Platyps             = 'latest'
    ModuleBuilder       = 'latest'
    ChangelogManagement = 'latest'
    Sampler             = 'latest'
    MarkdownLinkCheck   = 'latest'
    'Az.Accounts'       = '1.5.1'
    'Az.Resources'      = '1.3.1'
}
