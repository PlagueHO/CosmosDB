function Remove-CosmosDbUserDefinedFunction
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ -ArgumentName 'CollectionId' })]
        [System.String]
        $CollectionId,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbUserDefinedFunctionIdValid -Id $_ })]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/udfs/{1}' -f $CollectionId, $Id)

    $null = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Delete' `
        -ResourceType 'udfs' `
        -ResourcePath $resourcePath
}
