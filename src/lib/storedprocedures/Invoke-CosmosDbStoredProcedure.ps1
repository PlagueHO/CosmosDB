function Invoke-CosmosDbStoredProcedure
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $PartitionKey,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbStoredProcedureIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $StoredProcedureParameter
    )

    $PSBoundParameters.Remove('CollectionId') | Out-Null
    $PSBoundParameters.Remove('Id') | Out-Null

    $resourcePath = ('colls/{0}/sprocs/{1}' -f $CollectionId, $Id)

    $headers = @{}
    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $headers += @{
            'x-ms-documentdb-partitionkey' = '["' + ($PartitionKey -join '","') + '"]'
        }
        $PSBoundParameters.Remove('PartitionKey') | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('Debug'))
    {
        $headers += @{
            'x-ms-documentdb-script-enable-logging' = $true
        }
        $PSBoundParameters.Remove('Debug') | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('StoredProcedureParameter'))
    {
        $body = ConvertTo-Json -InputObject $StoredProcedureParameter -Depth 10 -Compress
        $PSBoundParameters.Remove('StoredProcedureParameter') | Out-Null
    }
    else
    {
        $body = '[]'
    }

    <#
        Because the headers of this request will contain important information
        then we need to use a plain web request.
    #>
    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
        -ResourceType 'sprocs' `
        -ResourcePath $resourcePath `
        -Headers $headers `
        -Body $body

    if ($result.Headers.'x-ms-documentdb-script-log-results')
    {
        $logs = [Uri]::UnescapeDataString($result.Headers.'x-ms-documentdb-script-log-results').Trim()
        Write-Verbose -Message $($LocalizedData.StoredProcedureScriptLogResults -f $Id, $logs)
    }

    if ($result.Content)
    {
        return (ConvertFrom-Json -InputObject $result.Content)
    }
}
