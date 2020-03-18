function Get-CosmosDbUserDefinedFunction
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
        [ValidateScript({ Assert-CosmosDbUserDefinedFunctionIdValid -Id $_ })]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')

    $resourcePath = ('colls/{0}/udfs' -f $CollectionId)

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'udfs' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)

        $userDefinedFunction = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'udfs' `
            -ResourcePath $resourcePath

        $body = ConvertFrom-Json -InputObject $result.Content
        $userDefinedFunction = $body.UserDefinedFunctions
    }

    if ($userDefinedFunction)
    {
        return (Set-CosmosDbUserDefinedFunctionType -UserDefinedFunction $userDefinedFunction)
    }
}
