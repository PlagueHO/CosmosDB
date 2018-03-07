---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbCollectionIncludedPath

## SYNOPSIS
Creates an indexing policy included path object that can be
added to an Indexing Policy.

## SYNTAX

```
New-CosmosDbCollectionIncludedPath [[-Path] <String>] [[-Index] <Index[]>] [<CommonParameters>]
```

## DESCRIPTION
This function will return an indexing policy included path
object that can be added to an Indexing Policy.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Path for which the indexing behavior applies to.
Index paths
start with the root (/) and typically end with the ?
wildcard
operator, denoting that there are multiple possible values for
the prefix.
For example, to serve
SELECT * FROM Families F WHEREF.familyName = "Andersen", you
must include an index path for /familyName/?
in the collection's
index policy.

Index paths can also use the * wildcard operator to specify the
behavior for paths recursively under the prefix.
For example, /payload/*
can be used to include everything under the payload property
from indexing.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: /*
Accept pipeline input: False
Accept wildcard characters: False
```

### -Index
This is an array of included path index objects that were
created by New-CosmosDbCollectionIncludedPath.

```yaml
Type: Index[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Path.IncludedPath

## NOTES

## RELATED LINKS
