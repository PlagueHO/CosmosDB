function New-CosmosDbResponseException
{
    [CmdletBinding()]
    [OutputType([CosmosDB.ResponseException])]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [Alias('Exception')]
        [System.Exception]
        $InputObject
    )

    process
    {
        # Create the target CosmosDB.ResponseException
        $responseException = [CosmosDB.ResponseException]::new($InputObject.Message)

        switch ($InputObject)
        {
            { $_ -is [Microsoft.PowerShell.Commands.HttpResponseException] }
            {
                # PowerShell 7.0+
                $httpResponse = $InputObject.Response
                $responseException.StatusCode = $httpResponse.StatusCode
            }

            { $_ -is [System.Net.WebException] }
            {
                # PowerShell 5.1
                $webResponse = $InputObject.Response
                if ($webResponse -is [System.Net.HttpWebResponse])
                {
                    $responseException.StatusCode = $webResponse.StatusCode
                }
            }

            default {
                throw "Unsupported exception type: $($InputObject.GetType().FullName)"
            }
        }

        return $responseException
    }
}
