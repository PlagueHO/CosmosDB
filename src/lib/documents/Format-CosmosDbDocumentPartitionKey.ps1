<#
    .SYNOPSIS
    Helper function that assembles the partition key from an array
    for use in the 'x-ms-documentdb-partitionkey' header.
#>
function Format-CosmosDbDocumentPartitionKey
{

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Object[]]
        $PartitionKey
    )

    $formattedPartitionKey = @()

    foreach ($key in $PartitionKey)
    {
        if ($key -is [System.String])
        {
            $formattedPartitionKey += "`"$key`""
        }
        elseif ($key -is [System.Int16] -or $key -is [System.Int32] -or $key -is [System.Int64])
        {
            $formattedPartitionKey += $key
        }
        else
        {
            New-CosmosDbInvalidArgumentException `
                -Message ($LocalizedData.ErrorPartitionKeyUnsupportedType -f $key, $key.GetType().FullName) `
                -ArgumentName 'PartitionKey'
        }
    }

    return '[' + ($formattedPartitionKey -join ',') + ']'
}
