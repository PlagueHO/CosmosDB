function Set-CosmosDbAttachment
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
        [ValidateScript({ Assert-CosmosDbDocumentIdValid -Id $_ -ArgumentName 'DocumentId' })]
        [System.String]
        $DocumentId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbAttachmentIdValid -Id $_ })]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbAttachmentIdValid -Id $_ -ArgumentName 'NewId' })]
        [System.String]
        $NewId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $PartitionKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Media,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Slug
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')
    $null = $PSBoundParameters.Remove('Id')

    $resourcePath = ('colls/{0}/docs/{1}/attachments/{2}' -f $CollectionId, $DocumentId, $Id)

    $headers = @{}
    $bodyObject = @{}

    if ($PSBoundParameters.ContainsKey('NewId'))
    {
        $null = $PSBoundParameters.Remove('NewId')
        $bodyObject += @{ id = $NewId }
    }
    else
    {
        $bodyObject += @{ id = $Id }
    }

    if ($PSBoundParameters.ContainsKey('ContentType'))
    {
        $null = $PSBoundParameters.Remove('ContentType')
        $bodyObject += @{ contentType = $ContentType }
    }

    if ($PSBoundParameters.ContainsKey('Media'))
    {
        $null = $PSBoundParameters.Remove('Media')
        $bodyObject += @{ media = $Media }
    }

    if ($PSBoundParameters.ContainsKey('Slug'))
    {
        $null = $PSBoundParameters.Remove('Slug')
        $headers += @{
            'Slug' = $Slug
        }
    }

    if ($PSBoundParameters.ContainsKey('PartitionKey'))
    {
        $null = $PSBoundParameters.Remove('PartitionKey')
        $headers += @{
            'x-ms-documentdb-partitionkey' = '["' + ($PartitionKey -join '","') + '"]'
        }
    }

    $body = ConvertTo-Json -InputObject $bodyObject

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Put' `
        -ResourceType 'attachments' `
        -ResourcePath $resourcePath `
        -Body $body `
        -Headers $headers

    $attachment = ConvertFrom-Json -InputObject $result.Content

    if ($attachment)
    {
        return (Set-CosmosDbAttachmentType -Attachment $attachment)
    }
}
