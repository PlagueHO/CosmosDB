---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbInvalidOperationException

## SYNOPSIS

Creates and throws an invalid operation exception.

## SYNTAX

```powershell
New-CosmosDbInvalidOperationException [[-Message] <String>] [[-ErrorRecord] <ErrorRecord>] [<CommonParameters>]
```

## DESCRIPTION

Creates and throws an invalid operation exception.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> New-CosmosDbInvalidOperationException -Message 'Invalid operation'
```

Raise an invalid operation exception.

### EXAMPLE 2

```powershell
PS C:\>New-CosmosDbInvalidOperationException -Message 'Invalid operation' -ErrorRecord $errorRecord
```

Raise an invalid operation exception and attach the PowerShell
automation error record to it.

## PARAMETERS

### -Message

The message explaining why this error is being thrown.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorRecord

The error record containing the exception that is
causing this terminating error.

```yaml
Type: ErrorRecord
Parameter Sets: (All)
Aliases:

Required: False
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

## NOTES

## RELATED LINKS
