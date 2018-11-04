function Get-CosmosDbDocumentResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
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
        $Id
    )

    return ('dbs/{0}/colls/{1}/docs/{2}' -f $Database, $CollectionId, $Id)
}
