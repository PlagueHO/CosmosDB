@{
    PSDependOptions       = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = ''
        }
    }
    invokeBuild           = 'latest'
    PSScriptAnalyzer      = 'latest'
    Pester                = '4.10.1'
    Plaster               = 'latest'
    Platyps               = 'latest'
    ModuleBuilder         = 'latest'
    ChangelogManagement   = 'latest'
    Sampler               = 'latest'
    'Sampler.GitHubTasks' = 'latest'
    MarkdownLinkCheck     = 'latest'
    'Az.Accounts'         = '2.2.8'
    'Az.Resources'        = '1.3.1'
}
