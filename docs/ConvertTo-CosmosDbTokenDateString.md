---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# ConvertTo-CosmosDbTokenDateString

## SYNOPSIS

Convert a DateTime object into the format required for use
in a CosmosDB Authorization Token and request header.

## SYNTAX

```powershell
ConvertTo-CosmosDbTokenDateString [-Date] <DateTime> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet converts a DateTime object into the format required
by the Authorization Token and in the request header.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> $dttoken = ConvertTo-CosmosDbTokenDateString -Date (Get-Date)
```

Generate date string for use in a CosmosDB token.

## PARAMETERS

### -Date

This is the DateTime object to convert.

```yaml
Type: DateTime
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

### System.String

## NOTES

## RELATED LINKS
