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
New-CosmosDbAuthorizationToken [-Key] <SecureString> [[-KeyType] <String>] [[-Method] <String>]
 [[-ResourceType] <String>] [[-ResourceId] <String>] [-Date] <DateTime> [[-TokenVersion] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is used to create an Authorization Token to
pass in the header of a Rest API request to an Azure CosmosDB.
The Authorization token that is generated must match the
other parameters in the header of the request that is passed.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Key
The key to be used to access this CosmosDB.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyType
The type of key that will be used to access ths CosmosDB.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
This is the Rest API method that will be made in the request
this token is being generated for.

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

### -ResourceType
This is type of resource being accessed in the CosmosDB.
For example: users, colls

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId
This is the resource Id of the CosmosDB being accessed.
This is in the format 'dbs/{database}' and must match the
the value in the path of the URI that the request is made
to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
This is the DateTime of the request being made.
This must
be included in the 'x-ms-date' parameter in the request
header and match what was provided to this cmdlet.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
