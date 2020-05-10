---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionExcludedPath

## SYNOPSIS

Creates an indexing policy excluded path object that can be
added to an Indexing Policy.

## SYNTAX

```powershell
New-CosmosDbCollectionExcludedPath [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This function will return an indexing policy excluded path
object that can be added to an Indexing Policy.

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

Create a new collection with a custom indexing policy that
excludes the path '/test/*'.

## PARAMETERS

### -Path

Path that is excluded from indexing.
Index paths start with the root (/) and typically end with the * wildcard operator.
For example, /payload/* can be used to exclude everything under the payload property
from indexing.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: /*
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Path.ExcludedPath

## NOTES

## RELATED LINKS

[https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes](https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes)
