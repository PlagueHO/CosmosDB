function Get-CosmosDbDocument
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
        [ValidateScript({ Assert-CosmosDbDocumentIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $PartitionKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Int32]
        $MaxItemCount = -1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContinuationToken,

        [Parameter()]
        [ValidateSet('Strong', 'Bounded', 'Session', 'Eventual')]
        [System.String]
        $ConsistencyLevel,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $SessionToken,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $PartitionKeyRangeId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Query,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Hashtable[]]
        $QueryParameters,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean]
        $QueryEnableCrossPartition = $False,

        [Alias("ResultHeaders")]
        [Parameter()]
        [ref]
        $ResponseHeader
    )

    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('MaxItemCount')
    $null = $PSBoundParameters.Remove('ContinuationToken')
    $null = $PSBoundParameters.Remove('ConsistencyLevel')
    $null = $PSBoundParameters.Remove('SessionToken')
    $null = $PSBoundParameters.Remove('PartitionKeyRangeId')
    $null = $PSBoundParameters.Remove('Query')
    $null = $PSBoundParameters.Remove('QueryParameters')
    $null = $PSBoundParameters.Remove('QueryEnableCrossPartition')

    if ($PSBoundParameters.ContainsKey('ResponseHeader'))
    {
        $ResponseHeaderPassed = $true
        $null = $PSBoundParameters.Remove('ResponseHeader')
    }

    $resourcePath = ('colls/{0}/docs' -f $CollectionId)
    $method = 'Get'
    $headers = @{}

    if (-not [String]::IsNullOrEmpty($Id))
    {
        # A document Id has been specified
        if ($PSBoundParameters.ContainsKey('PartitionKey'))
        {
            $headers += @{
                'x-ms-documentdb-partitionkey' = '["' + ($PartitionKey -join '","') + '"]'
            }
            $null = $PSBoundParameters.Remove('PartitionKey')
        }

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method $method `
            -Headers $headers `
            -ResourceType 'docs' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)

        $content = Repair-CosmosDbDocumentEncoding -Content $result.Content
        $document = ConvertFrom-JSON -InputObject $content
    }
    else
    {
        $body = ''

        if (-not [String]::IsNullOrEmpty($Query))
        {
            # A query has been specified
            $method = 'Post'

            $headers += @{
                'x-ms-documentdb-isquery' = $True
            }

            if ($QueryEnableCrossPartition -eq $True)
            {
                $headers += @{
                    'x-ms-documentdb-query-enablecrosspartition' = $True
                }
            }

            # Set the content type to application/query+json for querying
            $null = $PSBoundParameters.Add('ContentType', 'application/query+json')

            # Create the body JSON for the query
            $bodyObject = @{ query = $Query }
            if (-not [String]::IsNullOrEmpty($QueryParameters))
            {
                $bodyObject += @{ parameters = $QueryParameters }
            }
            $body = ConvertTo-Json -InputObject $bodyObject
        }
        else
        {
            if (-not [String]::IsNullOrEmpty($PartitionKeyRangeId))
            {
                $headers += @{
                    'x-ms-documentdb-partitionkeyrangeid' = $PartitionKeyRangeId
                }
            }
        }

        # The following headers apply when querying documents or just getting a list
        if ($PSBoundParameters.ContainsKey('PartitionKey'))
        {
            $headers += @{
                'x-ms-documentdb-partitionkey' = Format-CosmosDbDocumentPartitionKey -PartitionKey $PartitionKey
            }
            $null = $PSBoundParameters.Remove('PartitionKey')
        }

        $headers += @{
            'x-ms-max-item-count' = $MaxItemCount
        }

        if (-not [String]::IsNullOrEmpty($ContinuationToken))
        {
            $headers += @{
                'x-ms-continuation' = $ContinuationToken
            }
        }

        if (-not [String]::IsNullOrEmpty($ConsistencyLevel))
        {
            $headers += @{
                'x-ms-consistency-level' = $ConsistencyLevel
            }
        }

        if (-not [String]::IsNullOrEmpty($SessionToken))
        {
            $headers += @{
                'x-ms-session-token' = $SessionToken
            }
        }

        <#
            Because the headers of this request will contain important information
            then we need to use a plain web request.
        #>
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method $method `
            -ResourceType 'docs' `
            -ResourcePath $resourcePath `
            -Headers $headers `
            -Body $body

        $content = Repair-CosmosDbDocumentEncoding -Content $result.Content
        $body = ConvertFrom-JSON -InputObject $content
        $document = $body.Documents

        if ($ResponseHeaderPassed)
        {
            # Return the result headers
            $ResponseHeader.value = $result.Headers
        }
    }

    if ($document)
    {
        return (Set-CosmosDbDocumentType -Document $document)
    }
}
