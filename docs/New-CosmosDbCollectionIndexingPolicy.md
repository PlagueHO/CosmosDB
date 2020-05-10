---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionIndexingPolicy

## SYNOPSIS

Creates an indexing policy object that can be passed to the
New-CosmosDbCollection function.

## SYNTAX

```powershell
New-CosmosDbCollectionIndexingPolicy [[-Automatic] <Boolean>] [[-IndexingMode] <String>]
 [[-IncludedPath] <IncludedPath[]>] [[-ExcludedPath] <ExcludedPath[]>]
 [[-CompositeIndex] <Element[][]>] [<CommonParameters>]
```

## DESCRIPTION

This function will return an indexing policy object that can
be passed to the New-CosmosDbCollection function to configure
custom indexing policies on a collection.

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

Create a new collection with a custom indexing policy.

### Example 2

```powershell
PS C:\> $indexIncludedPath = New-CosmosDbCollectionIncludedPath -Path '/*'
PS C:\> $compositeIndexElements = @(
            @(
                (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Ascending')
            ),
            @(
                (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
                (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Descending')
            )
        )
PS C:\> $indexingPolicy = New-CosmosDbCollectionIndexingPolicy -Automatic $true -IndexingMode Consistent -IncludedPath $indexIncludedPath -CompositeIndex $compositeIndexElements
PS C:\> New-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection' -PartitionKey 'account' -IndexingPolicy $indexingPolicy
```

Create a new collection with a custom indexing policy containing composite indexes.

## PARAMETERS

### -Automatic

Indicates whether automatic indexing is on or off.
The default value is True, thus all documents are indexed.
Setting the value to False would allow manual configuration of indexing paths.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludedPath

The array containing document paths to be excluded from indexing.

```yaml
Type: ExcludedPath[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompositeIndex

An array of arrays containing composite index elements created by
New-CosmosDbCollectionCompositeIndexElement.

```yaml
Type: Element[][]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: @(@())
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludedPath

The array containing document paths to be indexed.
By default, two paths are included: the / path which specifies that all document
paths be indexed, and the _ts path, which indexes for a timestamp range comparison.

```yaml
Type: IncludedPath[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexingMode

By default, the indexing mode is Consistent.
This means that indexing occurs synchronously during insertion, replacment or
deletion of documents.
To have indexing occur asynchronously, set the indexing mode to lazy.
A collection that has an index mode of None has no index associated with it. This
is commonly used if Azure Cosmos DB is used as a key-value storage, and documents
are accessed only by their ID property.
When using None as the indexing mode, automatic must be set to False.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Consistent, Lazy, None

Required: False
Position: 1
Default value: Consistent
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Policy

## NOTES

## RELATED LINKS
