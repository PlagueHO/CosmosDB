function Get-CosmosDbAttachmentResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ -ArgumentName 'Database' })]
        [System.String]
        $Database,

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
        $Id
    )

    return ('dbs/{0}/colls/{1}/docs/{2}/attachments/{3}' -f $Database, $CollectionId, $DocumentId, $Id)
}
