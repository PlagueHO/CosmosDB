function Get-CosmosDbCollection
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([Object])]
    param
    (
        [Alias('Connection')]
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

        [Alias('Name')]
        [Parameter()]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Int32]
        $MaxItemCount = -1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContinuationToken,

        [Parameter()]
        [ref]
        $ResponseHeader
    )

    $null = $PSBoundParameters.Remove('MaxItemCount')
    $null = $PSBoundParameters.Remove('ContinuationToken')

    if ($PSBoundParameters.ContainsKey('ResponseHeader'))
    {
        $ResponseHeaderPassed = $true
        $null = $PSBoundParameters.Remove('ResponseHeader')
    }

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'colls' `
            -ResourcePath ('colls/{0}' -f $Id)

        $collection = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        $headers = @{
            'x-ms-max-item-count' = $MaxItemCount
        }

        if (-not [String]::IsNullOrEmpty($ContinuationToken))
        {
            $headers += @{
                'x-ms-continuation' = $ContinuationToken
            }
        }

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'colls' `
            -Headers $headers

        $body = ConvertFrom-Json -InputObject $result.Content
        $collection = $body.DocumentCollections
    }


    if ($ResponseHeaderPassed)
    {
        # Return the result headers
        $ResponseHeader.value = $result.Headers
    }

    if ($collection)
    {
        return (Set-CosmosDbCollectionType -Collection $collection)
    }
}
