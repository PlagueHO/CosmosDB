function Remove-CosmosDbAccount
{

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
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

        [Parameter()]
        [Switch]
        $AsJob,

        [Parameter()]
        [Switch]
        $Force
    )

    if ($Force -or `
            $PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldRemoveAzureCosmosDBAccount -f $Name, $ResourceGroupName)))
    {
        Write-Verbose -Message $($LocalizedData.RemovingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

        $removeAzResource_parameters = $PSBoundParameters + @{
            ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
            ApiVersion   = '2015-04-08'
        }
        $removeAzResource_parameters['Force'] = $true

        $null = Remove-AzResource @removeAzResource_parameters
    }
}
