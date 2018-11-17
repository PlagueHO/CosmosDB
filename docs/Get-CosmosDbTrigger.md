---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbTrigger

## SYNOPSIS

Return the triggers for a Cosmos DB database collection.

## SYNTAX

### Context (Default)

```powershell
Get-CosmosDbTrigger -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -CollectionId <String> [-Id <String>] [<CommonParameters>]
```

### Account

```powershell
Get-CosmosDbTrigger -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 -CollectionId <String> [-Id <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will return the triggers for a specified collection
in a Cosmos DB database.
If an Id is specified then only the specified trigger will be returned.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection'
```

Get a list of triggers from a collection in the database.

### Example 2

```powershell
PS C:\> Get-CosmosDbTrigger -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'eventhub'
```

Get the 'eventhub' trigger from a collection in the database.

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

This is the id of the collection to get the triggers for.

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

This is the id of the trigger to return.

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

### System.Object

## NOTES

## RELATED LINKS
