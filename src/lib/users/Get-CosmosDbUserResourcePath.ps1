function Get-CosmosDbUserResourcePath
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Id
    )

    return ('dbs/{0}/users/{1}' -f $Database, $Id)
}
