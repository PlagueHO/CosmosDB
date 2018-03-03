---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbOffer

## SYNOPSIS
Return the offers in a CosmosDB account.

## SYNTAX

### Context (Default)
```
Get-CosmosDbOffer -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Id <String>] [-Query <String>]
 [<CommonParameters>]
```

### Account
```
Get-CosmosDbOffer -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Id <String>] [-Query <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will return the offers in a CosmosDB account.
If the Id is specified then only the offer matching this
Id will be returned, otherwise all offers will be returned.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Context
This is an object containing the context information of
the CosmosDB account that will be accessed.
It should be created
by \`New-CosmosDbContext\`.

If the context contains a database it will be ignored.

```yaml
Type: Context
Parameter Sets: Context
Aliases: Connection

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Account
The account name of the CosmosDB to access.

```yaml
Type: String
Parameter Sets: Account
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key
The key to be used to access this CosmosDB.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
This is the Id of the offer to get.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
A SQL select query to execute to select the offers.
This
should not be specified if Id is specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
