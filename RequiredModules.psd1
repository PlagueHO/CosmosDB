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
    'Az.Accounts'         = '2.19.0'
    'Az.Resources'        = '6.16.2'
    'Az.CosmosDB'         = '1.14.2' # Required by integration tests
}
