---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionIncludedPathIndex

## SYNOPSIS

Creates an indexing policy included path index object that
can be added to an Included Path of an Indexing Policy.

## SYNTAX

```powershell
New-CosmosDbCollectionIncludedPathIndex [-Kind] <String> [-DataType] <String> [[-Precision] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION

This function will return an indexing policy included path index object that can
be added to an included path Indexing Policy.

## EXAMPLES

### Example 1

```powershell
PS C:\> $indexStringRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType String -Precision -1
PS C:\> $indexNumberRange = New-CosmosDbCollectionIncludedPathIndex -Kind Range -DataType Number -Precision -1
PS C:\> $indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*' -Index $indexStringRange, $indexNumberRange
PS C:\> $indexExcludedPath = New-CosmosDbCollectionExcludedPath -Path '/test/*'
PS C:\> $indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath -ExcludedPath $indexExcludedPath
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -PartitionKey 'account' -IndexingPolicy $indexingPolicy
```

Create a new collection with a custom indexing policy with both a
string and a number included path indexes.

## PARAMETERS

### -DataType

This is the datatype for which the indexing behavior is applied to.
Can be String, Number, Point, Polygon, or LineString.
Note that Booleans and nulls are automatically indexed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: String, Number, Point, Polygon, LineString

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind

The Kind of the index.
Range indexes are useful for equality, range comparisons and sorting.
Spatial indexes are useful for spatial queries.

The Hash index Kind is no longer supported by Cosmos DB.
A warning will be displayed if the Hash index Kind is used.
The Hash index Kind will be removed in a future BREAKING release of the
Cosmos DB module.
See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-kind
for more information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Hash, Range, Spatial

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Precision

The Precision parameter is no longer supported by Cosmos DB and will be
ignored. The maximum precision of -1 will always be used for Range indexes.
A warning will be displayed if the Precision parameter is passed.
The Precision parameter will be removed in a future BREAKING release of the
Cosmos DB module.
See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-precision
for more information.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Path.Index

## NOTES

## RELATED LINKS

[https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes](https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes)
