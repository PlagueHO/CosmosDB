function New-CosmosDbAttachment
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
        $DocumentId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

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

    $resourcePath = ('colls/{0}/docs/{1}/attachments' -f $CollectionId, $DocumentId)

    $headers = @{}
    $bodyObject = @{}

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')
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
        $headers += @{
            'Slug' = $Slug
        }
        $null = $PSBoundParameters.Remove('Slug')
    }

    $body = ConvertTo-Json -InputObject $bodyObject

    $result = Invoke-CosmosDbRequest @PSBoundParameters `
        -Method 'Post' `
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