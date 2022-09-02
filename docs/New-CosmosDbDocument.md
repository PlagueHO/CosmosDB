---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbDocument

## SYNOPSIS

Create a new document for a collection in a Cosmos DB database.

## SYNTAX

### Context (Default)

```powershell
New-CosmosDbDocument -Context <Context> [-KeyType <String>] [-Key <SecureString>]
 [-Database <String>] -CollectionId <String> -DocumentBody <String>
 [-IndexingDirective <String>] [-Upsert <Boolean>] [-PartitionKey <Object[]>]
 [-Encoding <String>] [-ReturnJson <switch>] [<CommonParameters>]
```

### Account

```powershell
New-CosmosDbDocument -Account <String> [-KeyType <String>] [-Key <SecureString>]
 [-Database <String>] -CollectionId <String> -DocumentBody <String>
 [-IndexingDirective <String>] [-Upsert <Boolean>] [-PartitionKey <Object[]>]
 [-Encoding <String>] [-ReturnJson <switch>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a document for a collection in a Cosmos DB.

## EXAMPLES

### Example 1

```powershell
PS C:\> $document = @"
{
    `"id`": `"$([Guid]::NewGuid().ToString())`",
    `"content`": `"Some string`",
    `"more`": `"Some other string`"
}
"@
PS C:\> New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentBody $document
}
```

Create a new document in a non-partitioned collection in a database.

### Example 2

```powershell
PS C:\> $document = @"
{
    `"id`": `"en-us`",
    `"locale`": `"English (US)`"
}
"@
PS C:\> New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -DocumentBody $document -PartitionKey 'en-us'
```

Create a new document in the 'en-us' in a partitioned collection in a database.

### Example 3

```powershell
PS C:\> $document = @"
{
    `"id`": `"en-us`",
    `"content`": `"杉本 司`"
}
"@
PS C:\> New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -DocumentBody $document -Encoding 'UTF-8'
```

Create a new document containing UTF-8 encoded strings in a non-partitioned collection
in a database.

### Example 4

```powershell
PS C:\> $document = @"
{
    `"id`": `"en-us`",
    `"content`": {
        `"key`": `"lower case key`",
        `"KEY`": `"upper case key`"
    }
}
"@
PS C:\> New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'PartitionedCollection' -DocumentBody $document -ReturnJson
```

Create a new document containing a document with JSON that can not be returned as
an object due to keys that differ only in case. This will return
the output as JSON.

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

This is the Id of the collection to create the document for.

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

### -DocumentBody

This is the body of the document.
It must be formatted as a JSON string and contain the Id value of
the document to create.

The document body must contain an id field.

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

### -Encoding

This parameter allows the Encoding to be set to UTF-8 for documents that contain
non-ASCII characters. If this parameter is not specified the default encoding is
used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Default, UTF-8

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndexingDirective

Include adds the document to the index.
Exclude omits the document from indexing.
The default for indexing behavior is determined by the automatic
property's value in the indexing policy for the collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Include, Exclude

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

### -PartitionKey

The partition key value(s) for the document to be created.
Must be included if and only if the collection is created with a partitionKey
definition.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Upsert

Include adds the document to the index.
Exclude omits the document from indexing.
The default for indexing behavior is determined by the automatic
property's value in the indexing policy for the collection.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnJson

Prevents the information returned by Cosmos DB from the request to be converted
into an object. This switch is required if the document being added to Cosmos DB
has key names that are duplicates, differing only in case.

```yaml
Type: switch
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
