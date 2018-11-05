function New-CosmosDbStoredProcedure
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
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ -ArgumentName 'CollectionId' })]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbStoredProcedureIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $StoredProcedureBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('StoredProcedureBody')

    $resourcePath = ('colls/{0}/sprocs' -f $CollectionId)

    $requestBody = Convert-CosmosDbRequestBody -RequestBodyObject @{
        id = $id
        body = $StoredProcedureBody
    }

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath `
        -Body $requestBody

    $storedProcedure = ConvertFrom-Json -InputObject $result.Content

    if ($storedProcedure)
    {
        return (Set-CosmosDbStoredProcedureType -StoredProcedure $storedProcedure)
    }
}
