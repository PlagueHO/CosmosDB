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

```
New-CosmosDbCollectionExcludedPath [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will return an indexing policy excluded path
object that can be added to an Indexing Policy.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Path
Path that is excluded from indexing.
Index paths start with the
root (/) and typically end with the * wildcard operator..
For example, /payload/* can be used to exclude everything under
the payload property from indexing.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### CosmosDB.IndexingPolicy.Path.ExcludedPath

## NOTES

## RELATED LINKS
