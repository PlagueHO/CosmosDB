function Get-CosmosDbCollectionSize
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Alias("Connection")]
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ -ArgumentName 'Account' })]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ })]
        [System.String]
        $Id
    )

    <#
        per https://docs.microsoft.com/en-us/azure/cosmos-db/monitor-accounts,
        The quota and usage information for the collection is returned in the
        x-ms-resource-quota and x-ms-resource-usage headers in the response.
    #>

    $null = $PSBoundParameters.Remove('Id')

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Get' `
        -ResourceType 'colls' `
        -ResourcePath ('colls/{0}' -f $Id)

    $usageItems = @{}
    $resources = ($result.headers["x-ms-resource-usage"]).Split(';', [System.StringSplitOptions]::RemoveEmptyEntries)

    foreach ($resource in $resources)
    {
        [System.String] $k, $v = $resource.Split('=')
        $usageItems[$k] = $v
    }

    if ($usageItems)
    {
        return $usageItems
    }
}
