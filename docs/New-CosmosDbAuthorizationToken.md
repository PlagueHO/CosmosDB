---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# New-CosmosDbAuthorizationToken

## SYNOPSIS
Create a new Authorization Token to be used with in a
Rest API request to CosmosDB.

## SYNTAX

```
New-CosmosDbAuthorizationToken [[-Verb] <String>] [[-ResourceType] <String>] [[-ResourceId] <String>]
 [-Date] <String> [-Key] <String> [[-KeyType] <String>] [[-TokenVersion] <String>]
```

## DESCRIPTION
This cmdlet is used to create an Authorization Token to
pass in the header of a Rest API request to an Azure CosmosDB.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Verb
{{Fill Verb Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceType
{{Fill ResourceType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId
{{Fill ResourceId Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
{{Fill Date Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key
{{Fill Key Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyType
{{Fill KeyType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -TokenVersion
{{Fill TokenVersion Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 7
Default value: 1.0
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

