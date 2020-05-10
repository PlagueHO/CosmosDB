---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionCompositeIndexElement

## SYNOPSIS

Creates an indexing policy composite index element.

## SYNTAX

```powershell
New-CosmosDbCollectionCompositeIndexElement [-Path] <String> [[-Order] <String>]
[<CommonParameters>]
```

## DESCRIPTION

This function creates an element for a composite index. A composite index consists
of two or more elements and when combined can be applied as part of a collection
index policy.

## EXAMPLES

### Example 1

```powershell
PS C:\> $compositeIndex = @(
    (New-CosmosDbCollectionCompositeIndexElement -Path '/name' -Order 'Ascending'),
    (New-CosmosDbCollectionCompositeIndexElement -Path '/age' -Order 'Ascending')
)
```

Create a composite index consisting of two index elements.

## PARAMETERS

### -Order

The order that the composite index element should be sorted in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Ascending, Descending

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path of the composite index element.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable,
-Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### CosmosDB.IndexingPolicy.CompositeIndex.Element

## NOTES

## RELATED LINKS

[https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes](https://docs.microsoft.com/en-nz/azure/cosmos-db/index-policy#composite-indexes)
