---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbCollection

## SYNOPSIS

Return the collections in a CosmosDB database.

## SYNTAX

### Context (Default)

```powershell
Get-CosmosDbCollection -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [<CommonParameters>]
```

### Account

```powershell
Get-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will return the collections in a CosmosDB database.
If the Id is specified then only the collection matching this
Id will be returned, otherwise all collections will be returned.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbCollection -Context $cosmosDbContext
```

Gets a list of collections in a database.

### Example 2

```powershell
PS C:\> Get-CosmosDbCollection -Context $cosmosDbContext -Id 'MyNewCollection'
```

Get a the MyNewCollection collection from a database.

## PARAMETERS

### -Context

This is an object containing the context information of the CosmosDB database
that will be deleted. It should be created by \`New-CosmosDbContext\`.

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

### -Database

The name of the database to access in the CosmosDB account.

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

### -Id

This is the id of the collection to get.
If not specified
all collections in the database will be returned.

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
