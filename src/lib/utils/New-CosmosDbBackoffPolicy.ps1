function New-CosmosDbBackoffPolicy
{

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.Int32]
        $MaxRetries = 10,

        [Parameter()]
        [ValidateSet('Default', 'Additive', 'Linear', 'Exponential', 'Random')]
        [System.String]
        $Method = 'Default',

        [Parameter()]
        [ValidateRange(0, 3600000)]
        [System.Int32]
        $Delay = 0
    )

    $backoffPolicy = New-Object -TypeName 'CosmosDB.BackoffPolicy' -Property @{
        MaxRetries = $MaxRetries
        Method     = $Method
        Delay      = $Delay
    }

    return $backoffPolicy
}
