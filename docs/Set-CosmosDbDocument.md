---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbDocument

## SYNOPSIS

Update a document from a Cosmos DB collection.

## SYNTAX

### Context (Default)

```powershell
Set-CosmosDbDocument -Context <Context> [-Database <String>] [-Key <SecureString>] -CollectionId <String>
 -Id <String> -DocumentBody <String> [-IndexingDirective <String>] [-PartitionKey <String>]
 [-Encoding <String>] [-ETag <String>] [<CommonParameters>]
```

### Account

```powershell
Set-CosmosDbDocument -Account <String> [-Database <String>] [-Key <SecureString>] [-KeyType <String>]
 -CollectionId <String> -Id <String> -DocumentBody <String> [-IndexingDirective <String>]
 [-PartitionKey <String>] [-Encoding <String>] [-ETag <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will update an existing document in a Cosmos DB collection.

## EXAMPLES

### Example 1

```powershell
PS C:\> $newDocument = @"
{
    `"id`": `"ac12345`",
    `"content`": `"New string`",
    `"more`": `"Another new string`"
}
"@
PS C:\> Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'ac12345' -DocumentBody $newDocument
```

Replace the content of a document in a collection in the database.

### Example 2

```powershell
PS C:\> $newDocument = @"
{
    `"id`": `"ac12345`",
    `"content`": `"杉本 司`"
}
"@
PS C:\> Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'ac12345' -DocumentBody $newDocument -Encoding 'UTF-8'
```

Replace the content of a document in a collection in the database with a
document using UTF-8 encoding.

### Example 3

```powershell
PS C:\> $document = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'ac12345' -ConsistencyLevel Strong
PS C:\> $newDocument = @"
{
    `"id`": `"$($document.id)`",
    `"counter`": $($document.counter + 1)
}
"@
PS C:\> Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'MyNewCollection' -Id 'ac12345' -DocumentBody $newDocument -Encoding 'UTF-8' -ETag $document._etag
```

Increment the counter of a document. Make sure that the document has not been
modified between get and set operations by supplying the ETag from the original
document.

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

This is the Id of the collection to update the document for.

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

This is the body of the document to update.
It must be
formatted as a JSON string and contain the Id value of the
document to create.

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

### -ETag

This parameter checks if the document has been updated since last get
operation. The update operation will fail if the ETag is out of date. To set
this parameter use the *_etag* field from the received document.

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

This is the Id of the document to update.

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

### -IndexingDirective

Include includes the document in the indexing path while
Exclude omits the document from indexing.

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
Parameter Sets: Account
Aliases:
Accepted values: master, resource

Required: False
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartitionKey

The partition key value for the document to be deleted.
Required if and must be specified only if the collection is
created with a partitionKey definition.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
