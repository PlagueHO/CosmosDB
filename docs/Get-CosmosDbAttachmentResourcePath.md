---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbAttachmentResourcePath

## SYNOPSIS

Return the resource path for an attachment object.

## SYNTAX

```powershell
Get-CosmosDbAttachmentResourcePath [-Database] <String> [-CollectionId] <String> [-DocumentId] <String>
 [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns the resource identifier for an
attachment object.

## EXAMPLES

### Example 1

```powershell
Get-CosmosDbAttachmentResourcePath -Database 'MyDatabase' -CollectionId 'MyNewCollection' -DocumentId 'ac12345' -Id 'Image_1'
```

Generate a resource path for attachment 'Image_1' in document 'ac12345'
in collection 'MyNewCollection' in database 'MyDatabase'.

## PARAMETERS

### -Database

This is the database containing the attachment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CollectionId

This is the Id of the collection containing the attachment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentId

This is the Id of the document containing the attachment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

This is the Id of the attachment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
