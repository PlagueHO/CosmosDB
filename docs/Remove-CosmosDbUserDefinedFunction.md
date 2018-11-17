---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Remove-CosmosDbUserDefinedFunction

## SYNOPSIS

Delete a user defined function from a Cosmos DB collection.

## SYNTAX

### Context (Default)

```powershell
Remove-CosmosDbUserDefinedFunction -Context <Context> [-Database <String>] [-Key <SecureString>]
 [-KeyType <String>] -CollectionId <String> [-Id <String>] [<CommonParameters>]
```

### Account

```powershell
Remove-CosmosDbUserDefinedFunction -Account <String> [-Database <String>] [-Key <SecureString>]
 [-KeyType <String>] -CollectionId <String> [-Id <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will delete a user defined function in a Cosmos DB from a collection.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-CosmosDbUserDefinedFunction -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'udfTax'
```

Remove a user defined function 'udfTax' from a collection in the database.

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

### -CollectionId

This is the Id of the collection to delete the user defined function from.

```yaml
Type: String
Parameter Sets: (All)
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

### -Database

The name of the database to access in the Cosmos DB account.

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

This is the Id of the user defined function to delete.

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
