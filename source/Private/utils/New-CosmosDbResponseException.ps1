function New-CosmosDbResponseException
{
    [CmdletBinding()]
    [OutputType([CosmosDB.ResponseException])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [Alias('Exception')]
        [System.Exception]
        $InputObject
    )

    process
    {
        $message = $InputObject.Message

        switch ($InputObject)
        {
            { $_ -is [Microsoft.PowerShell.Commands.HttpResponseException] }
            {
                Write-Verbose -Message $($LocalizedData.NewCosmosDbResponseExceptionHttpResponseExceptionMessage -f $message)
                # PowerShell 7.0+ - just use the message
            }

            { $_ -is [System.Net.WebException] }
            {
                Write-Verbose -Message $($LocalizedData.NewCosmosDbResponseExceptionWebException -f $message)
                # PowerShell 5.1 - attempt to use the message in the Response
                $webResponse = $InputObject.Response
                if ($webResponse -is [System.Net.HttpWebResponse])
                {
                    $message = $webResponse.Message
                }
            }

            default {
                Write-Verbose -Message $($LocalizedData.NewCosmosDbResponseExceptionDefaultException -f $message)
                # Other exception types don't set any other properties
            }
        }

        $responseException = [CosmosDB.ResponseException]::new($message)
        return $responseException
    }
}
