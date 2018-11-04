function Get-CosmosDbUserResourcePath
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
        [ValidateScript({ Assert-CosmosDbUserIdValid -Id $_ })]
        [System.String]
        $Id
    )

    return ('dbs/{0}/users/{1}' -f $Database, $Id)
}
