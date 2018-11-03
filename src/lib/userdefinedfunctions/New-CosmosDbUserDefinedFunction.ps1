function New-CosmosDbUserDefinedFunction
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
        [ValidateNotNullOrEmpty()]
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserDefinedFunctionBody
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('UserDefinedFunctionBody')

    $resourcePath = ('colls/{0}/udfs' -f $CollectionId)

    $UserDefinedFunctionBody = ((($UserDefinedFunctionBody -replace '`n', '\n') -replace '`r', '\r') -replace '"', '\"')

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'udfs' `
        -ResourcePath $resourcePath `
        -Body "{ `"id`": `"$id`", `"body`" : `"$UserDefinedFunctionBody`" }"

    $userDefinedFunction = ConvertFrom-Json -InputObject $result.Content

    if ($userDefinedFunction)
    {
        return (Set-CosmosDbUserDefinedFunctionType -UserDefinedFunction $userDefinedFunction)
    }
}
