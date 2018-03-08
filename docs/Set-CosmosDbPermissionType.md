---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbPermissionType

## SYNOPSIS

Set the custom Cosmos DB User types to the permission
returned by an API call.

## SYNTAX

```powershell
Set-CosmosDbPermissionType [-Permission] <Object> [<CommonParameters>]
```

## DESCRIPTION

This function applies the custom types to the permission returned
by an API call.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-CosmosDbPermissionType -Permission $permission
```

Apply the permission data type to the object provided
permission.

## PARAMETERS

### -Permission

This is the permission that is returned by a user API call.

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
