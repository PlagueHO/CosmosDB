<#
.SYNOPSIS
    Extracts detailed exception information from an ErrorRecord for Cosmos DB requests.

.DESCRIPTION
    The Get-CosmosDbRequestExceptionString function retrieves detailed exception information
    from an ErrorRecord object. It handles both PowerShell Core and Windows PowerShell
    environments by using the appropriate method to extract the exception details.

    In PowerShell Core, it uses the ErrorDetails property. In Windows PowerShell, it reads
    the response stream from the exception object.

.PARAMETER ErrorRecord
    The ErrorRecord object containing the exception details. This parameter is mandatory.

.OUTPUTS
    System.String
        Returns a string containing the detailed exception information.

.EXAMPLE
    $errorRecord = Get-ErrorRecordFromSomeOperation
    $exceptionDetails = Get-CosmosDbRequestExceptionString -ErrorRecord $errorRecord

    Retrieves the detailed exception information from the provided ErrorRecord.
#>
function Get-CosmosDbRequestExceptionString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($PSEdition -eq 'Core')
    {
        # PowerShell Core: Use ErrorDetails
        return $ErrorRecord.ErrorDetails
    }
    else
    {
        # Windows PowerShell: Read the response stream
        if ($null -ne $ErrorRecord.Exception.Response)
        {
            $exceptionStream = $ErrorRecord.Exception.Response.GetResponseStream()
            $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $exceptionStream
            return $streamReader.ReadToEnd()
        }
        else
        {
            return 'Exception response is null.'
        }
    }
}
