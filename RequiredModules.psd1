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
    'Az.Accounts'         = '4.2.0'
    'Az.Resources'        = '8.0.0'
    'Az.CosmosDB'         = '1.18.0' # Required by integration tests
}
