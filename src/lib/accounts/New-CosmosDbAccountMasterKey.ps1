function New-CosmosDbAccountMasterKey
{

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    [OutputType([SecureString])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter(ParameterSetName = 'AzureAccount')]
        [ValidateSet('PrimaryMasterKey', 'SecondaryMasterKey', 'PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey')]
        [System.String]
        $MasterKeyType = 'PrimaryMasterKey'
    )

    Write-Verbose -Message $($LocalizedData.RegeneratingAzureCosmosDBAccountMasterKey -f $Name, $ResourceGroupName, $MasterKeyType)

    $invokeAzureRmResourceAction_parameters = @{
        Name              = $Name
        ResourceGroupName = $ResourceGroupName
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
        Action            = 'regenerateKey'
        Force             = $true
        Parameters        = @{ keyKind = ($MasterKeyType -replace 'MasterKey','')}
        ErrorAction       = 'Stop'
    }

    Invoke-AzureRmResourceAction @invokeAzureRmResourceAction_parameters
}
