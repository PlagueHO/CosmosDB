---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbEntraIdToken

## SYNOPSIS

Generates a secure string token for use with Azure Cosmos DB by
calling the Entra ID service using the Get-AzAccessToken cmdlet.

## SYNTAX

```powershell
Get-CosmosDbEntraIdToken [[-Endpoint] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Generates a secure string token for use with Azure Cosmos DB by
calling the Entra ID service using the Get-AzAccessToken cmdlet.
This requires that a user or service principal has been authenticated
using the Connect-AzAccount cmdlet. If the user is not authenticated,
the cmdlet will return null but display an error message.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-CosmosDbEntraIdToken
```

This will return a secure string token that can be used with Azure Cosmos DB.
The token will use the default resource URI of https://cosmos.azure.com.

## PARAMETERS

### -Endpoint

This parameter allows the resource URI of the token to be specified. The default
value is https://cosmos.azure.com.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Security.SecureString

## NOTES

## RELATED LINKS
