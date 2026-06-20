<#
    .SYNOPSIS
    Sets the type name for transactional batch operation objects.
    
    .DESCRIPTION
    This function adds the custom type name 'CosmosDB.TransactionalBatchOperation' to 
    batch operation objects to enable proper PowerShell formatting and type handling.
    
    .PARAMETER BatchOperations
    An array of batch operation objects that will have their type name set to 
    'CosmosDB.TransactionalBatchOperation'.
#>
function Set-CosmosDbTransactionalBatchOperationType
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $BatchOperations
    )

    if ($PSCmdlet.ShouldProcess('Batch Operations', 'Set CosmosDB.TransactionalBatchOperation type'))
    {
        foreach ($item in $BatchOperations)
        {
            $item.PSObject.TypeNames.Insert(0, 'CosmosDB.TransactionalBatchOperation')
        }
    }

    return $BatchOperations
}
