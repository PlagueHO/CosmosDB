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
        $statusCode = $null

        switch ($InputObject)
        {
            { $_ -is [Microsoft.PowerShell.Commands.HttpResponseException] }
            {
                # PowerShell 7.0+
                $httpResponse = $InputObject.Response
                $message = $httpResponse.Message
                $statusCode = $httpResponse.StatusCode
            }

            { $_ -is [System.Net.WebException] }
            {
                # PowerShell 5.1
                $message = $InputObject.Message
                $webResponse = $InputObject.Response
                if ($webResponse -is [System.Net.HttpWebResponse])
                {
                    $message = $webResponse.Message
                    $statusCode = $webResponse.StatusCode
                }
            }

            default {
                # Other exception types don't set any other properties
            }
        }

        $responseException = [CosmosDB.ResponseException]::new($message, $statusCode)
        return $responseException
    }
}
