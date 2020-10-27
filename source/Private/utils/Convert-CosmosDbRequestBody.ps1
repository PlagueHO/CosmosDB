function Convert-CosmosDbRequestBody
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Object]
        $RequestBodyObject
    )

    <#
        On PowerShell Core 6.0.x, ConvertTo-Json does not correctly escape this
        string. See https://github.com/PowerShell/PowerShell/issues/7693.

        This means that on PowerShell Core, certain strings when passed as
        Stored Procedure or Function bodies will not be accepted.

        This means that this issue https://github.com/PlagueHO/CosmosDB/issues/137
        needs to remain open.
    #>
    return ConvertTo-Json -InputObject $RequestBodyObject -Depth 100 -Compress
}
