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
Get-CosmosDbEntraIdToken [[-Environment] <Environment>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
Get-CosmosDbEntraIdToken [-Endpoint <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Generates a secure string token for use with Azure Cosmos DB by
calling the Entra ID service using the Get-AzAccessToken cmdlet.
This requires that a user or service principal has been authenticated
using the Connect-AzAccount cmdlet. If the user is not authenticated,
the cmdlet will return null but display an error message.

The `Environment` parameter set resolves the correct Azure AD resource URL
for the specified cloud environment. The `Endpoint` parameter set allows an
explicit resource URL to be provided for custom or non-standard scenarios.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-CosmosDbEntraIdToken
```

This will return a secure string token using the default AzureCloud environment
resource URI of https://cosmos.azure.com.

### Example 2
```powershell
PS C:\> Get-CosmosDbEntraIdToken -Environment AzureUSGovernment
```

This will return a secure string token using the Azure US Government resource
URI of https://cosmos.azure.us.

### Example 3
```powershell
PS C:\> Get-CosmosDbEntraIdToken -Endpoint 'https://cosmos.azure.com'
```

This will return a secure string token using the explicitly specified resource URI.

## PARAMETERS

### -Environment

Specifies the Azure cloud environment. The cmdlet resolves the correct Azure AD
resource URL for the environment:
- AzureCloud: https://cosmos.azure.com
- AzureUSGovernment: https://cosmos.azure.us
- AzureChinaCloud: https://cosmos.azure.cn

This parameter cannot be used together with `-Endpoint`.

```yaml
Type: CosmosDB.Environment
Parameter Sets: Environment
Aliases:

Required: False
Position: 0
Default value: AzureCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -Endpoint

This parameter allows the Azure AD resource URI of the token to be specified
explicitly. Use this for custom or non-standard cloud deployments.

This parameter cannot be used together with `-Environment`.

```yaml
Type: String
Parameter Sets: Endpoint
Aliases:

Required: False
Position: Named
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
