---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbAttachment

## SYNOPSIS

Create a new attachment for a document in a CosmosDB database.

## SYNTAX

### Context (Default)

```powershell
New-CosmosDbAttachment -Context <Context> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -CollectionId <String> -DocumentId <String> [-Id <String>] [-ContentType <String>] [-Media <String>]
 [-Slug <String>] [<CommonParameters>]
```

### Account

```powershell
New-CosmosDbAttachment -Account <String> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -CollectionId <String> -DocumentId <String> [-Id <String>] [-ContentType <String>] [-Media <String>]
 [-Slug <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a attachment for a document in a CosmosDB.

## EXAMPLES

### Example 1

```powershell
New-CosmosDbAttachment -Context $cosmosDbContext -CollectionId 'MyNewCollection' -DocumentId 'ac12345' -Id 'image_1' -ContentType 'image/jpg' -Media 'www.bing.com'
```

Create an attachment on a document in a collection.

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

### -CollectionId

This is the Id of the collection to create the attachment in.

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

### -DocumentId

This is the Id of the document to create the attachment on.

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

### -Id

Not Required to be set when attaching raw media.
This is a user settable property.
It is the unique name that identifies the attachment, i.e. no two attachments
will share the same id.
The id must not exceed 255 characters.

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

### -ContentType

Not Required to be set when attaching raw media.
This is a user settable property.
It notes the content type of the attachment.

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

### -Media

Not Required to be set when attaching raw media.
This is the URL link or file path where the attachment resides.

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

### -Slug

The name of the attachment.
This is only required when raw media is submitted to the Azure Cosmos DB
attachment storage.

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
