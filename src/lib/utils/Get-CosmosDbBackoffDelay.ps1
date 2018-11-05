function Get-CosmosDbBackoffDelay
{

    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [CosmosDB.BackoffPolicy]
        $BackoffPolicy,

        [Parameter()]
        [System.Int32]
        $Retry = 0,

        [Parameter()]
        [System.Int32]
        $RequestedDelay = 0
    )

    if ($null -ne $BackoffPolicy)
    {
        # A back-off policy has been provided
        Write-Verbose -Message $($LocalizedData.CollectionProvisionedThroughputExceededWithBackoffPolicy)

        if ($Retry -le $BackoffPolicy.MaxRetries)
        {
            switch ($BackoffPolicy.Method)
            {
                'Default'
                {
                    $backoffPolicyDelay = $backoffPolicy.Delay
                }

                'Additive'
                {
                    $backoffPolicyDelay = $RequestedDelay + $backoffPolicy.Delay
                }

                'Linear'
                {
                    $backoffPolicyDelay = $backoffPolicy.Delay * ($Retry + 1)
                }

                'Exponential'
                {
                    $backoffPolicyDelay = $backoffPolicy.Delay * [Math]::pow(($Retry + 1),2)
                }

                'Random'
                {
                    $backoffDelayMin = -($backoffPolicy.Delay/2)
                    $backoffDelayMax = $backoffPolicy.Delay/2
                    $backoffPolicyDelay = $backoffPolicy.Delay + (Get-Random -Minimum $backoffDelayMin -Maximum $backoffDelayMax)
                }
            }

            if ($backoffPolicyDelay -gt $RequestedDelay)
            {
                $delay = $backoffPolicyDelay
                Write-Verbose -Message $($LocalizedData.BackOffPolicyAppliedPolicyDelay -f $BackoffPolicy.Method, $backoffPolicyDelay, $requestedDelay)
            }
            else
            {
                $delay = $requestedDelay
                Write-Verbose -Message $($LocalizedData.BackOffPolicyAppliedRequestedDelay -f $BackoffPolicy.Method, $backoffPolicyDelay, $requestedDelay)
            }

            return $delay
        }
        else
        {
            Write-Verbose -Message $($LocalizedData.CollectionProvisionedThroughputExceededMaxRetriesHit -f $BackoffPolicy.MaxRetries)
            return $null
        }
    }
    else
    {
        # A back-off policy has not been defined
        Write-Verbose -Message $($LocalizedData.CollectionProvisionedThroughputExceededNoBackoffPolicy)
        return $null
    }
}
