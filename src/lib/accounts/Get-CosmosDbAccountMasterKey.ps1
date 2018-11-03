function Get-CosmosDbAccountMasterKey
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

    Write-Verbose -Message $($LocalizedData.GettingAzureCosmosDBAccountMasterKey -f $Name, $ResourceGroupName, $MasterKeyType)

    $action = 'listKeys'
    if ($MasterKeyType -in ('PrimaryReadonlyMasterKey', 'SecondaryReadonlyMasterKey'))
    {
        # Use the readonlykey Action if a ReadOnly key is required
        $action = 'readonlykeys'
    }

    $invokeAzureRmResourceAction_parameters = @{
        Name              = $Name
        ResourceGroupName = $ResourceGroupName
        ResourceType      = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion        = '2015-04-08'
        Action            = $action
        Force             = $true
        ErrorAction       = 'Stop'
    }

    $resource = Invoke-AzureRmResourceAction @invokeAzureRmResourceAction_parameters

    if ($resource)
    {
        return ConvertTo-SecureString `
            -String ($resource.$MasterKeyType) `
            -AsPlainText `
            -Force
    }
}
