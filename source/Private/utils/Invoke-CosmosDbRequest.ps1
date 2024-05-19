function Invoke-CosmosDbRequest
{
    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([System.String])]
    param
    (
        [Alias('Connection')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [ValidateNotNullOrEmpty()]
        [CosmosDB.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [System.String]
        $Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateSet('Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        [System.String]
        $Method = 'Get',

        [Parameter(Mandatory = $True)]
        [ValidateSet('attachments', 'colls', 'dbs', 'docs', 'users', 'permissions', 'triggers', 'sprocs', 'udfs', 'offers')]
        [System.String]
        $ResourceType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourcePath,

        [Parameter()]
        [System.String]
        $Body = '',

        [Parameter()]
        [ValidateSet('2014-08-21', '2015-04-08', '2015-06-03', '2015-08-06', '2015-12-16', '2016-07-11', '2017-01-19', '2017-02-22', '2017-05-03', '2017-11-15', '2018-06-18', '2018-08-31', '2018-08-31', '2018-09-17', '2018-12-31')]
        [System.String]
        $ApiVersion = '2018-09-17',

        [Parameter()]
        [System.Collections.Hashtable]
        $Headers = @{ },

        [Parameter()]
        [System.String]
        $ContentType = 'application/json',

        [Parameter()]
        [ValidateSet('Default', 'UTF-8')]
        [System.String]
        $Encoding = 'Default'
    )

    if ($PSCmdlet.ParameterSetName -eq 'Account')
    {
        $Context = New-CosmosDbContext -Account $Account -Database $Database -Key $Key -KeyType $KeyType
    }

    if (-not ($PSBoundParameters.ContainsKey('Database')))
    {
        $Database = $Context.Database
    }

    # Generate the resource link value that will be used in the URI and to generate the resource id
    switch ($resourceType)
    {
        'dbs'
        {
            # Request for a database object (not containined in a database)
            if ([System.String]::IsNullOrEmpty($ResourcePath))
            {
                $ResourceLink = 'dbs'
            }
            else
            {
                $resourceLink = $ResourcePath
                $resourceId = $resourceLink
            }
        }

        'offers'
        {
            # Request for an offer object (not contained in a database)
            if ([System.String]::IsNullOrEmpty($ResourcePath))
            {
                $ResourceLink = 'offers'
            }
            else
            {
                $resourceLink = $ResourcePath
                $resourceId = ($ResourceLink -split '/')[1].ToLowerInvariant()
            }
        }

        default
        {
            # Request for an object that is within a database
            if ([System.String]::IsNullOrEmpty($Database))
            {
                New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorMalformedContextDatabaseEmpty)
            }

            $resourceLink = ('dbs/{0}' -f $Database)


            if ($PSBoundParameters.ContainsKey('ResourcePath'))
            {
                $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourcePath)
            }
            else
            {
                $resourceLink = ('{0}/{1}' -f $resourceLink, $ResourceType)
            }

            # Generate the resource Id from the resource link value
            $resourceElements = [System.Collections.ArrayList] ($resourceLink -split '/')

            if (($resourceElements.Count % 2) -eq 0)
            {
                $resourceId = $resourceLink
            }
            else
            {
                $resourceElements.RemoveAt($resourceElements.Count - 1)
                $resourceId = $resourceElements -Join '/'
            }
        }
    }

    if ([System.String]::IsNullOrEmpty($Context.BaseUri))
    {
        New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorMalformedContextBaseUriEmpty)
    }

    # Generate the URI from the base connection URI and the resource link
    $baseUri = $Context.BaseUri.ToString()
    $uri = [uri]::New(('{0}{1}' -f $baseUri, $resourceLink))

    # Try to build the authorization headers from the Context Resource token if there are any
    $authorizationHeaders = Get-CosmosDbAuthorizationHeaderFromContextResourceToken `
        -Context $Context `
        -ResourceLink $resourceLink

    if ($null -eq $authorizationHeaders)
    {
        <#
             A token in the context that matched the resource link could not be found
             So try to use the Entra Id token in the context.
        #>
        if ([System.String]::IsNullOrEmpty($Context.EntraIdToken))
        {
            <#
                Neither a resource token in the context or an EntraIdToken was found
                So try to use the Key in the context to generate the authorization headers.
            #>
            if ([System.String]::IsNullOrEmpty($Context.Key))
            {
                New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorAuthorizationKeyEmpty)
            }

            $authorizationHeaders = Get-CosmosDbAuthorizationHeaderFromContext `
                -Key $Context.Key `
                -KeyType $Context.KeyType `
                -Method $Method `
                -ResourceType $ResourceType `
                -ResourceId $resourceId `
                -Date (Get-Date)
        }
        else
        {
            $authorizationHeaders = Get-CosmosDbAuthorizationHeaderFromContextEntraId `
                -Context $Context `
                -Date(Get-Date)
        }
    }

    if ($null -eq $authorizationHeaders)
    {
        # This generally shouldn't occur, but we need to check just in case
        New-CosmosDbInvalidOperationException -Message ($LocalizedData.ErrorAuthorizationHeadersEmpty)
    }

    $Headers += $authorizationHeaders
    $Headers.Add('x-ms-version', $ApiVersion)

    $invokeWebRequestParameters = @{
        Uri             = $uri
        Headers         = $Headers
        Method          = $method
        ContentType     = $ContentType
        UseBasicParsing = $true
    }

    if ($Method -in ('Put', 'Post', 'Patch'))
    {
        if ($Method -eq 'Patch')
        {
            $invokeWebRequestParameters['ContentType'] = 'application/json-patch+json'
        }

        if ($Encoding -eq 'UTF-8')
        {
            <#
                An encoding type of UTF-8 was passed so explictly set this in the
                request and convert to the body string to UTF8 bytes.
            #>
            $invokeWebRequestParameters['ContentType'] = ('{0}; charset={1}' -f $invokeWebRequestParameters['ContentType'], $Encoding)
            $invokeWebRequestParameters += @{
                Body = [System.Text.Encoding]::UTF8.GetBytes($Body)
            }
        }
        else
        {
            $invokeWebRequestParameters += @{
                Body = $Body
            }
        }
    }

    $requestComplete = $false
    $retry = 0

    <#
        This should initially be set to $false and changed to $true when fatal error
        is caught
    #>
    $fatal = $false

    do
    {
        try
        {
            $requestResult = Invoke-WebRequest @invokeWebRequestParameters
            $requestComplete = $true
        }
        catch [System.Net.WebException], [Microsoft.PowerShell.Commands.HttpResponseException]
        {
            if ($_.Exception.Response.StatusCode -eq 429)
            {
                <#
                    The exception was caused by exceeding provisioned throughput
                    so determine is we should delay and try again or exit
                #>
                $retryAfterHeader = $_.Exception.Response.Headers | Where-Object -Property Key -eq 'x-ms-retry-after-ms'
                if ($retryAfterHeader)
                {
                    [System.Int32] $retryAfter = $retryAfterHeader.Value[0]
                }
                else
                {
                    [System.Int32] $retryAfter = 0
                    Write-Verbose -Message $($LocalizedData.ErrorTooManyRequestsWithNoRetryAfter)
                }

                $delay = Get-CosmosDbBackoffDelay `
                    -BackOffPolicy $Context.BackoffPolicy `
                    -Retry $retry `
                    -RequestedDelay $retryAfter

                # A null delay means retries have been exceeded or no back-off policy specified
                if ($null -ne $delay)
                {
                    $retry++
                    Write-Verbose -Message $($LocalizedData.WaitingBackoffPolicyDelay -f $retry, $delay)
                    Start-Sleep -Milliseconds $delay
                    continue
                }
                else
                {
                    Write-Verbose -Message $($LocalizedData.ErrorTooManyRequests)
                }
            }

            if ($_.Exception.Response)
            {
                <#
                    Write out additional exception information into the verbose stream
                    In a future version a custom exception type for CosmosDB that
                    contains this additional information.
                #>

                if ($PSEdition -eq 'Core')
                {
                    # https://get-powershellblog.blogspot.com/2017/11/powershell-core-web-cmdlets-in-depth.html#L13
                    $exceptionResponse = $_.ErrorDetails
                }
                else
                {
                    $exceptionStream = $_.Exception.Response.GetResponseStream()
                    $streamReader = New-Object -TypeName System.IO.StreamReader -ArgumentList $exceptionStream
                    $exceptionResponse = $streamReader.ReadToEnd()
                }

                if ($exceptionResponse)
                {
                    Write-Verbose -Message $exceptionResponse
                }
            }

            # A non-recoverable exception occurred
            $fatal = $true

            Throw $_
        }
        catch
        {
            # A non-recoverable exception occurred
            $fatal = $true

            Throw $_
        }
    } while ($requestComplete -eq $false -and -not $fatal)

    # Display the Request Charge as a verbose message
    $requestCharge = [Uri]::UnescapeDataString($requestResult.Headers.'x-ms-request-charge').Trim()

    if ($requestCharge)
    {
        Write-Verbose -Message $($LocalizedData.RequestChargeResults -f $method, $uri, $requestCharge)
    }

    return $requestResult
}
