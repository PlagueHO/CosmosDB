---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Remove-CosmosDbDatabase

## SYNOPSIS

Delete a database from a Cosmos DB account.

## SYNTAX

### Context (Default)

```powershell
Remove-CosmosDbDatabase -Context <Context> [-Key <SecureString>] [-KeyType <String>] -Id <String>
 [<CommonParameters>]
```

### Account

```powershell
Remove-CosmosDbDatabase -Account <String> [-Key <SecureString>] [-KeyType <String>] -Id <String>
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will delete a database in Cosmos DB.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-CosmosDbDatabase -Context $cosmosDbContext -Id 'AnotherDatabase'
```

Delete the database 'AnotherDatabase' the Cosmos DB account.

## PARAMETERS

### -Account

The account name of the Cosmos DB to access.

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

### -Context

This is an object containing the context information of the Cosmos DB database
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

### -Id

This is the Id of the database to delete.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key

The key to be used to access this Cosmos DB.

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

The type of key that will be used to access ths Cosmos DB.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: master, resource

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
