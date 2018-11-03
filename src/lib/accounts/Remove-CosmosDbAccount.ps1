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

    $removeAzureRmResource_parameters = $PSBoundParameters + @{
        ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
        ApiVersion   = '2015-04-08'
    }

    if ($Force -or `
            $PSCmdlet.ShouldProcess('Azure', ($LocalizedData.ShouldRemoveAzureCosmosDBAccount -f $Name, $ResourceGroupName)))
    {
        Write-Verbose -Message $($LocalizedData.RemovingAzureCosmosDBAccount -f $Name, $ResourceGroupName)

        $null = Remove-AzureRmResource @removeAzureRmResource_parameters
    }
}
