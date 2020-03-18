function Get-CosmosDbDatabaseResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbDatabaseIdValid -Id $_ })]
        [System.String]
        $Id
    )

    return ('dbs/{0}' -f $Id)
}
