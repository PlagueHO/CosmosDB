<#
    .SYNOPSIS
        Repair ISO-8859-1 encoded string to UTF-8 to fix bug
        in Invoke-WebRequest and Invoke-RestMethod in Windows
        PowerShell.

    .DESCRIPTION
        This function is used to correct the encoding of UTF-8
        results that are returned by Invoke-WebRequest and
        Invoke-RestMethod in Windows PowerShell.

        An ancient bug in Invoke-WebRequest and Invoke-RestMethod
        causes UTF-8 encoded strings to be returned as ISO-8859-1.

        This issue does not exist in PowerShell Core, so the
        string is just returned as-is.

    .PARAMETER Content
        The string to convert encodings for

    .LINK
        https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/13685217-invoke-restmethod-and-invoke-webrequest-encoding-b
#>
function Repair-CosmosDbDocumentEncoding
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.String]
        $Content
    )

    if ($PSEdition -ne 'Core')
    {
        $encodingUtf8 = [System.Text.Encoding]::GetEncoding([System.Text.Encoding]::UTF8.CodePage)
        $codePageIso88591 = ([System.Text.Encoding]::GetEncodings() | Where-Object -Property Name -eq 'iso-8859-1').CodePage
        $encodingIso88591 = [System.Text.Encoding]::GetEncoding($codePageIso88591)
        $bytesUtf8 = $encodingUtf8.GetBytes($Content)
        $bytesIso88591 = [System.Text.Encoding]::Convert($encodingUtf8,$encodingIso88591,$bytesUtf8)

        return $encodingUtf8.GetString($bytesIso88591)
    }
    else
    {
        return $Content
    }
}
