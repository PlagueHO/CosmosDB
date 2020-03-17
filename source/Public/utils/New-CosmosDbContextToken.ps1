function New-CosmosDbContextToken
{

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Resource,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.DateTime]
        $TimeStamp,

        [Parameter()]
        [ValidateRange(600, 18000)]
        [System.Int32]
        $TokenExpiry = 3600,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Token
    )

    $contextToken = New-Object -TypeName 'CosmosDB.ContextToken' -Property @{
        Resource  = $Resource
        TimeStamp = $TimeStamp
        Expires   = $TimeStamp.AddSeconds($TokenExpiry)
        Token     = $Token
    }

    return $contextToken
}
