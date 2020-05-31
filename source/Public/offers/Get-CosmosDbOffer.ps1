function Get-CosmosDbOffer
{

    [CmdletBinding(DefaultParameterSetName = 'Context')]
    [OutputType([Object])]
    param
    (
        [Alias('Connection')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Context')]
        [ValidateNotNullOrEmpty()]
        [CosmosDb.Context]
        $Context,

        [Parameter(Mandatory = $true, ParameterSetName = 'Account')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Account,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString]
        $Key,

        [Parameter()]
        [ValidateSet('master', 'resource')]
        [System.String]
        $KeyType = 'master',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Id,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Query
    )

    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $null = $PSBoundParameters.Remove('Id')

        $result = Invoke-CosmosDbRequest @PSBoundParameters `
            -Method 'Get' `
            -ResourceType 'offers' `
            -ResourcePath ('offers/{0}' -f $Id)

        $offer = ConvertFrom-Json -InputObject $result.Content
    }
    else
    {
        if (-not [System.String]::IsNullOrEmpty($Query))
        {
            $null = $PSBoundParameters.Remove('Query')

            # A query has been specified
            $headers += @{
                'x-ms-documentdb-isquery' = $True
            }

            # Set the content type to application/query+json for querying
            $null = $PSBoundParameters.Add('ContentType', 'application/query+json')

            # Create the body JSON for the query
            $bodyObject = @{ query = $Query }
            $body = ConvertTo-Json -InputObject $bodyObject

            $result = Invoke-CosmosDbRequest @PSBoundParameters `
                -Method 'Post' `
                -ResourceType 'offers' `
                -Headers $headers `
                -Body $body
        }
        else
        {
            $result = Invoke-CosmosDbRequest @PSBoundParameters `
                -Method 'Get' `
                -ResourceType 'offers'
        }

        $body = ConvertFrom-Json -InputObject $result.Content
        $offer = $body.Offers
    }

    if ($offer)
    {
        return (Set-CosmosDbOfferType -Offer $offer)
    }
}
