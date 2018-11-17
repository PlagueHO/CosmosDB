---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbCollectionSize

## SYNOPSIS

Return the size/usage properties associated with a collection in a Cosmos DB database.
While not officially documented, the below contains the list of properties and their expected usage:

collectionSize  : Size of the entire collection, including indexes.
documentsCount  : Count of documents in the collection.
documentsSize   : Size (in KB) of all documents in the collection.
documentSize    : Size (in MB) of all documents in the collection.
functions       : Count of functions in the collection.
storedProcedures: Count of stored procedures in the collection.
triggers        : Count of triggers in the collection.

## SYNTAX

### Context (Default)

```powershell
Get-CosmosDbCollectionSize -Context <Context> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [<CommonParameters>]
```

### Account

```powershell
Get-CosmosDbCollection -Account <String> [-Key <SecureString>] [-KeyType <String>] [-Database <String>]
 [-Id <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will return the size properties of a given collection in a Cosmos DB database.
The Id for the collection must be passed.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-CosmosDbCollectionSize -Context $cosmosDbContext -Id 'MyNewCollection'
```

Get the usage properties associated with MyNewCollection collection from a database.

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
containing the collection. It should be created by \`New-CosmosDbContext\`.

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

This is the id of the collection to get.

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
