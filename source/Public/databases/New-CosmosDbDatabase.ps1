function New-CosmosDbDatabase
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [Alias('Connection')]
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
        [Alias('Name')]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Id,

        [ValidateRange(400, 100000)]
        [System.Int32]
        $OfferThroughput,

        [Alias('AutopilotThroughput')]
        [ValidateRange(4000, 1000000)]
        [System.Int32]
        $AutoscaleThroughput
    )

    $null = $PSBoundParameters.Remove('Id')

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('OfferThroughput') -and `
        $PSBoundParameters.ContainsKey('AutoscaleThroughput'))
    {
        New-CosmosDbInvalidOperationException -Message $($LocalizedData.ErrorNewDatabaseThroughputParameterConflict)
    }

    if ($PSBoundParameters.ContainsKey('OfferThroughput'))
    {
        $headers += @{
            'x-ms-offer-throughput' = $OfferThroughput
        }
        $null = $PSBoundParameters.Remove('OfferThroughput')
    }

    if ($PSBoundParameters.ContainsKey('AutoscaleThroughput'))
    {
        $headers += @{
            'x-ms-cosmos-offer-autopilot-settings' = ConvertTo-Json -InputObject @{
                maxThroughput = $AutoscaleThroughput
            } -Compress
        }
        $null = $PSBoundParameters.Remove('AutoscaleThroughput')
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
