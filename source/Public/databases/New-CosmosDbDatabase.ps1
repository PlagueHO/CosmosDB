function New-CosmosDbDatabase
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

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateRange(400, 100000)]
        [System.Int32]
        $OfferThroughput
    )

    $null = $PSBoundParameters.Remove('Id')

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
        $headers += @{
            'x-ms-offer-throughput' = $OfferThroughput
        }
        $null = $PSBoundParameters.Remove('OfferThroughput')
    }

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'dbs' `
        -Headers $headers `
        -Body "{ `"id`": `"$id`" }"

    $database = ConvertFrom-Json -InputObject $result.Content

    if ($database)
    {
        return (Set-CosmosDbDatabaseType -Database $database)
    }
}
