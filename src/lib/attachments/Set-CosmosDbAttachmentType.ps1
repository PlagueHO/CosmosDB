function Set-CosmosDbAttachmentType
{

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $Attachment
    )

    foreach ($item in $Attachment)
    {
        $item.PSObject.TypeNames.Insert(0, 'CosmosDB.Attachment')
    }

    return $Attachment
}
