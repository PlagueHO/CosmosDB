function New-CosmosDbAccountMasterKey
{

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    [OutputType([SecureString])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbAccountNameValid -Name $_ })]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Assert-CosmosDbResourceGroupNameValid -ResourceGroupName $_ })]
        [System.String]
        $ResourceGroupName,

        [Parameter(ParameterSetName = 'AzureAccount')]
        [ValidateSet('PrimaryMasterKey', 'SecondaryMasterKey', 'PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey')]
        [System.String]
        $MasterKeyType = 'PrimaryMasterKey'
    )

    Write-Verbose -Message $($LocalizedData.RegeneratingAzureCosmosDBAccountMasterKey -f $Name, $ResourceGroupName, $MasterKeyType)

    $invokeAzResourceAction_parameters = @{
        Name              = $Name
        ResourceGroupName = $ResourceGroupName
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
        Action            = 'regenerateKey'
        Force             = $true
        Parameters        = @{ keyKind = ($MasterKeyType -replace 'MasterKey','')}
        ErrorAction       = 'Stop'
    }

    Invoke-AzResourceAction @invokeAzResourceAction_parameters
}
