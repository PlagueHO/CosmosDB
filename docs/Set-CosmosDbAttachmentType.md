---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbAttachmentType

## SYNOPSIS

Set the custom Cosmos DB Attachment types to the attachment
returned by an API call.

## SYNTAX

```powershell
Set-CosmosDbAttachmentType [-Attachment] <Object> [<CommonParameters>]
```

## DESCRIPTION

This function applies the custom types to the attachment
returned by an API call.

## EXAMPLES

### Example 1

```powershell
Set-CosmosDbAttachmentType -Attachment $attachment
```

Apply the attachment data type to the object provided attachment.

## PARAMETERS

### -Attachment

This is the attachment that is returned by an attachment API call.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
