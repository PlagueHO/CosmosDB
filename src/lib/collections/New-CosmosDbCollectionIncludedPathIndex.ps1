function New-CosmosDbCollectionIncludedPathIndex
{

    [CmdletBinding()]
    [OutputType([CosmosDB.IndexingPolicy.Path.Index])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Hash', 'Range', 'Spatial')]
        [System.String]
        $Kind,

        [Parameter(Mandatory = $true)]
        [ValidateSet('String', 'Number', 'Point', 'Polygon', 'LineString')]
        [System.String]
        $DataType,

        [Parameter()]
        [Int32]
        $Precision
    )

    # Validate the path index parameters
    switch ($Kind)
    {
        'Hash'
        {
            <#
                Index Hask kind has been deprecated and will result in default Range indexes
                being created instead. Hash indexes will be removed in a future breaking
                release.
                See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-kind
            #>
            Write-Warning `
                -Message $($LocalizedData.WarningNewCollectionIncludedPathIndexHashDeprecated)

            if ($DataType -notin @('String', 'Number'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'String, Number') `
                    -ArgumentName 'DataType'
            }
        }

        'Range'
        {
            if ($DataType -notin @('String', 'Number'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'String, Number') `
                    -ArgumentName 'DataType'
            }
        }

        'Spatial'
        {
            if ($DataType -notin @('Point', 'Polygon', 'LineString'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexInvalidDataType -f $Kind, $DataType, 'Point, Polygon, LineString') `
                    -ArgumentName 'DataType'
            }

            if ($PSBoundParameters.ContainsKey('Precision'))
            {
                New-CosmosDbInvalidArgumentException `
                    -Message $($LocalizedData.ErrorNewCollectionIncludedPathIndexPrecisionNotSupported -f $Kind) `
                    -ArgumentName 'Precision'
            }
        }
    }

    $index = New-Object -TypeName ('CosmosDB.IndexingPolicy.Path.Index' + $Kind)
    $index.Kind = $Kind
    $index.DataType = $DataType

    if ($PSBoundParameters.ContainsKey('Precision'))
    {
        <#
            Index Precision should always be -1 for Range and must not be passed for Spatial.
            The Precision parameter will be removed in a future breaking release.
            See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-precision
        #>
        Write-Warning `
            -Message $($LocalizedData.WarningNewCollectionIncludedPathIndexPrecisionDeprecated)
    }

    return $index
}
