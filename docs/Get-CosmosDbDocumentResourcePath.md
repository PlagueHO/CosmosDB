---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Get-CosmosDbDocumentResourcePath

## SYNOPSIS
Return the resource path for a document object.

## SYNTAX

```
Get-CosmosDbDocumentResourcePath [-Database] <String> [-CollectionId] <String> [-Id] <String>
```

## DESCRIPTION
This cmdlet returns the resource identifier for a
document object.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Database
This is the database containing the document.

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

### -CollectionId
This is the Id of the collection containing the
document.

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

### -Id
This is the Id of the document.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

