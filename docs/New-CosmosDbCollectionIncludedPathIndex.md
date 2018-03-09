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

### -Kind

The type of index.
Hash indexes are useful for equality
comparisons while Range indexes are useful for equality, range comparisons and sorting.
Spatial indexes are useful for spatial queries.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataType

This is the datatype for which the indexing behavior is applied to.
Can be String, Number, Point, Polygon, or LineString.
Note that Booleans and nulls are automatically indexed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Precision

The precision of the index.
Can be either set to -1 for maximum precision or between 1-8 for Number, and
1-100 for String.
Not applicable for Point, Polygon, and LineString data types.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Path.Index

## NOTES

## RELATED LINKS
