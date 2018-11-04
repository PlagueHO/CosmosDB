function Get-CosmosDbAttachment
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
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
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
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbCollectionIdValid -Id $_ })]
        [System.String]
        $CollectionId,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDocumentIdValid -Id $_ })]
        [System.String]
        $DocumentId,

        [Parameter()]
        [ValidateScript({ Assert-CosmosDbAttachmentIdValid -Id $_ })]
        [System.String]
        $Id
    )

    $null = $PSBoundParameters.Remove('CollectionId')
    $null = $PSBoundParameters.Remove('DocumentId')

    $resourcePath = ('colls/{0}/docs/{1}/attachments' -f $CollectionId, $DocumentId)

    if (-not [String]::IsNullOrEmpty($Id))
    {
        $null = $PSBoundParameters.Remove('Id')

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'attachments' `
            -ResourcePath ('{0}/{1}' -f $resourcePath, $Id)

        $attachment = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'attachments' `
            -ResourcePath $resourcePath

        $body = ConvertFrom-Json -InputObject $result.Content
        $attachment = $body.Attachments
    }

    if ($attachment)
    {
        return (Set-CosmosDbAttachmentType -Attachment $attachment)
    }
}
