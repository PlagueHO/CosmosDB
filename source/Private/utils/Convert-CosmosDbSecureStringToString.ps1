<#
    .SYNOPSIS
        Decrypt a Secure String back to a string.

    .PARAMETER SecureString
        The Secure String to decrypt.

    .NOTES
        Because ConvertFrom-SecureString does not decrypt a secure string to plain
        text in PS 5.1 or PS Core 6, then we will use the BSTR method to convert it
        for those versions.

        The BSTR method does not work on PS 7 on Linux.
        Issue raised: https://github.com/PowerShell/PowerShell/issues/12125
#>
function Convert-CosmosDbSecureStringToString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.Security.SecureString]
        $SecureString
    )

    process
    {
        if ($PSVersionTable.PSVersion.Major -ge 7)
        {
            $decryptedString = ConvertFrom-SecureString -SecureString $SecureString -AsPlainText
        }
        else
        {
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
            $decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        }

        return $decryptedString
    }
}
