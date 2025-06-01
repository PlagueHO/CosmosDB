function New-CosmosDbDocument
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DocumentBody,

        [Parameter()]
        [ValidateSet('Include', 'Exclude')]
        [System.String]
        $IndexingDirective,

        [Parameter()]
        [System.Boolean]
        $Upsert,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $PartitionKey,

        [Parameter()]
        [ValidateSet('Default', 'UTF-8')]
        [System.String]
        $Encoding = 'Default',

        [Parameter()]
        [switch]
        $ReturnJson,

        [Parameter()]
        [System.Int32]
        $MaximumRetryCount,

        [Parameter()]
        [System.Int32]
        $RetryIntervalSec = 5
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('Id')
    $null = $PSBoundParameters.Remove('DocumentBody')
    $null = $PSBoundParameters.Remove('ReturnJson')

    $resourcePath = ('colls/{0}/docs' -f $CollectionId)

    $headers = @{}

    if ($PSBoundParameters.ContainsKey('Upsert'))
    {
        $headers += @{
            'x-ms-documentdb-is-upsert' = $Upsert
        }
        $null = $PSBoundParameters.Remove('Upsert')
    }

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

    $invokeCosmosDbRequest_parameters = @{
        Method            = 'Post'
        ResourceType      = 'docs'
        ResourcePath      = $resourcePath
        Body              = $DocumentBody
        Headers           = $headers
        MaximumRetryCount = $MaximumRetryCount
        RetryIntervalSec  = $RetryIntervalSec
    }
    $result = Invoke-CosmosDbRequest @PSBoundParameters @invokeCosmosDbRequest_parameters

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
