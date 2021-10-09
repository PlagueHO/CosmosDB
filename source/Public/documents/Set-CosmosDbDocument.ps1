function Set-CosmosDbDocument
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter(ParameterSetName = 'Account')]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ -ArgumentName 'CollectionId' })]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDocumentIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentBody,

        [Parameter()]
        [ValidateSet('Include', 'Exclude')]
        [System.String]
        $IndexingDirective,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $PartitionKey,

        [Alias('IfMatch')]
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ETag,

        [Parameter()]
        [ValidateSet('Default', 'UTF-8')]
        [System.String]
        $Encoding = 'Default',

        [Parameter()]
        [switch]
        $ReturnJson,

        [Parameter()]
        [int]
        $MaximumRetryCount,

        [Parameter()]
        [int]
        $RetryIntervalSec = 5
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('DocumentBody')
    $null = $PSBoundParameters.Remove('ReturnJson')

    $resourcePath = ('colls/{0}/docs/{1}' -f $CollectionId, $Id)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('IndexingDirective'))
    {
        $headers += @{
            'x-ms-indexing-directive' = $IndexingDirective
        }
        $null = $PSBoundParameters.Remove('IndexingDirective')
    }

    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $headers += @{
            'x-ms-documentdb-partitionkey' = Format-CosmosDbDocumentPartitionKey -PartitionKey $PartitionKey
        }
        $null = $PSBoundParameters.Remove('PartitionKey')
    }

    if ($PSBoundParameters.ContainsKey('ETag'))
    {
        $headers += @{
            'If-Match' = $Etag
        }
        $null = $PSBoundParameters.Remove('ETag')
    }

    $Splat = @{
        Method            = 'Put'
        ResourceType      = 'docs'
        ResourcePath      = $resourcePath
        Body              = $DocumentBody
        Headers           = $headers
        MaximumRetryCount = $MaximumRetryCount
        RetryIntervalSec  = $RetryIntervalSec
    }
    $result = Invoke-CosmosDbRequest @PSBoundParameters @Splat

    if ($ReturnJson.IsPresent)
    {
        return $result.Content
    }
    else
    {
        try
        {
            $document = ConvertFrom-Json -InputObject $result.Content
        }
        catch
        {
            New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorConvertingDocumentJsonToObject)
        }

        if ($document)
        {
            return (Set-CosmosDbDocumentType -Document $document)
        }
    }
}
