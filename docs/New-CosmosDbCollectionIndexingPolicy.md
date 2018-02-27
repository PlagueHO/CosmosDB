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

```
New-CosmosDbCollectionIndexingPolicy [[-Automatic] <Boolean>] [[-IndexingMode] <String>]
 [[-IncludedPath] <IncludedPath[]>] [[-ExcludedPath] <ExcludedPath[]>] [<CommonParameters>]
```

## DESCRIPTION
This function will return an indexing policy object that can
be passed to the New-CosmosDbCollection function to configure
custom indexing policies on a collection.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Automatic
Indicates whether automatic indexing is on or off.
The default
value is True, thus all documents are indexed.
Setting the value
to False would allow manual configuration of indexing paths.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexingMode
By default, the indexing mode is Consistent.
This means that
indexing occurs synchronously during insertion, replacment or
deletion of documents.
To have indexing occur asynchronously,
set the indexing mode to lazy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Consistent
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludedPath
The array containing document paths to be indexed.
By default, two
paths are included: the / path which specifies that all document
paths be indexed, and the _ts path, which indexes for a timestamp
range comparison.

```yaml
Type: IncludedPath[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @()
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
Position: 4
Default value: @()
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
