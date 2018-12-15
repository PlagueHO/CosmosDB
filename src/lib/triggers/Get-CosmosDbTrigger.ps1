function Get-CosmosDbTrigger
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([Object])]
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
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ -ArgumentName 'CollectionId' })]
        [System.String]
        $CollectionId,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbTriggerIdValid -Id $_ })]
        [System.String]
        $Id
    )

    $PSBoundParameters.Remove('CollectionId') | Out-Null

    $resourcePath = ('colls/{0}/triggers' -f $CollectionId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $PSBoundParameters.Remove('Id') | Out-Null

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'triggers' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)

        $trigger = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'triggers' `
            -ResourcePath $resourcePath

        $body = ConvertFrom-Json -InputObject $result.Content
        $trigger = $body.Triggers
    }

    if ($trigger)
    {
        return (Set-CosmosDbTriggerType -Trigger $trigger)
    }
}
