---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# Get-CosmosDbUri

## SYNOPSIS
Return the URI of the CosmosDB that Rest APIs requests will
be sent to.

## SYNTAX

```
Get-CosmosDbUri [-Account] <String> [[-BaseUri] <String>]
```

## DESCRIPTION
This cmdlet returns the root URI of the CosmosDB.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Account
This is the name of the CosmosDB Account to get the URI
for.

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

### -BaseUri
{{Fill BaseUri Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: Documents.azure.com
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Uri

## NOTES

## RELATED LINKS

