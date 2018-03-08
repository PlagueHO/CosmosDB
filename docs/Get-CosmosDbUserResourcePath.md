---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbUserResourcePath

## SYNOPSIS

Return the resource path for a user object.

## SYNTAX

```powershell
Get-CosmosDbUserResourcePath [-Database] <String> [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns the resource identifier for a user
object.

## EXAMPLES

### Example 1

```powershell
Get-CosmosDbUserResourcePath -Database 'MyDatabase' -Id 'Mary'
```

Generate a resource path for user with Id 'Mary' in database 'MyDatabase'.

## PARAMETERS

### -Database

This is the database containing the user.

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

### -Id

This is the Id of the user.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
