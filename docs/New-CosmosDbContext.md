---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbContext

## SYNOPSIS

Create a context object containing the information required
to connect to a Cosmos DB.

## SYNTAX

### Account (Default)

```powershell
New-CosmosDbContext -Account <String> [-Database <String>]
 -Key <SecureString> [-KeyType <String>] [-BackoffPolicy <BackoffPolicy>]
 [-Environment <Environment>] [<CommonParameters>]
```

### AzureAccount

```powershell
New-CosmosDbContext -Account <String> [-Database <String>] -ResourceGroupName <String>
 [-MasterKeyType <String>] [-BackoffPolicy <BackoffPolicy>] [-Environment <Environment>]
 [<CommonParameters>]
```

### Token

```powershell
New-CosmosDbContext -Account <String> [-Database <String>] -Token <ContextToken[]>
 [-BackoffPolicy <BackoffPolicy>] [-Environment <Environment>] [<CommonParameters>]
```

### Emulator

```powershell
New-CosmosDbContext [-Database <String>] [-Key <SecureString>] [-Emulator]
 [-Port <Int16>] [-URI <String>] [-Token <ContextToken[]>]
 [-BackoffPolicy <BackoffPolicy>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet is used to simplify the calling of the Cosmos DB
cmdlets by providing all the context information in an
object that can be passed to the Cosmos DB cmdlets.

It can also retrieve the Cosmos DB primary or secondary key
from Azure Resource Manager.

A retry policy can be applied to the context to control
the behavior of "Too Many Request" (error code 429) responses
from Cosmos DB.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey
```

Creates a CosmosDB context specifying the master key manually.

### EXAMPLE 2

```powershell
PS C:\> Connect-AzAccount
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -ResourceGroupName 'MyCosmosDbResourceGroup' -MasterKeyType 'PrimaryMasterKey'
```

Creates a Cosmos DB context by logging into Azure and getting
it from the portal.

### EXAMPLE 3

```powershell
PS C:\> $cosmosDbContext = New-CosmosDbContext -Emulator
```

Creates a Cosmos DB context by using a local Cosmos DB Emulator.

### EXAMPLE 4

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $retryPolicy = New-CosmosDBRetryPolicy -MaxRetries 5 -Delay 2000
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -RetryPolicy $retryPolicy
```

Creates a Cosmos DB context specifying the master key manually. A
retry policy will be applied to the context that allows 5 retries
with a delay of 2 seconds between them.

### EXAMPLE 5

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your emulator master key' -AsPlainText -Force
PS C:\> $cosmosDbContext = New-CosmosDbContext -Emulator -URI 'mycosmosdb' -Key $primaryKey
```

Creates a Cosmos DB context by using a Cosmos DB Emulator installed onto
the machine 'mycosmosdb' with a custom key emulator key.

### EXAMPLE 6

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureGovCosmosDB' -Database 'MyDatabase' -Key $primaryKey -Environment 'AzureUSGovernment'
```

Creates a CosmosDB context specifying the master key manually connecting
to the Azure US Government cloud.

## PARAMETERS

### -Account

The account name of the Cosmos DB to access.

```yaml
Type: String
Parameter Sets: Account, AzureAccount, Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackoffPolicy

This a Back-off Policy object that controls the retry behavior for
requests using this context.

```yaml
Type: BackoffPolicy
Parameter Sets: (All)
Aliases:

Required: False
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

### -Emulator

Using this switch creates a context for a Cosmos DB emulator
installed onto the local host.

```yaml
Type: SwitchParameter
Parameter Sets: Emulator
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Environment

This is the Azure environment hosting the Cosmos DB account.

The supported values are:

- AzureCloud
- AzureUSGovernment

```yaml
Type: Environment
Parameter Sets: Account, AzureAccount, Token
Aliases:

Required: False
Position: Named
Default value: AzureCloud
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key

The key to be used to access the Cosmos DB account or Cosmos DB emulator.

If a Cosmos DB emulator is specified and this parameter is not passed then
the Cosmos DB key will default to the value specified on this page:
https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator#authenticating-requests

```yaml
Type: SecureString
Parameter Sets: Account
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: SecureString
Parameter Sets: Emulator
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyType

The type of key that will be used to access ths Cosmos DB.

Note: This parameter should always be set to master and
will be deprecated in a future release. Do not use it.

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

### -MasterKeyType

This is the master key type to use retrieve from Azure for
the Cosmos DB.

```yaml
Type: String
Parameter Sets: AzureAccount
Aliases:
Accepted values: PrimaryMasterKey, SecondaryMasterKey, PrimaryReadonlyMasterKey, SecondaryReadonlyMasterKey

Required: False
Position: Named
Default value: PrimaryMasterKey
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port

This is the port the Cosmos DB emulator is installed onto.
If not specified it will use the default port of 8081.

```yaml
Type: Int16
Parameter Sets: Emulator
Aliases:

Required: False
Position: Named
Default value: 8081
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName

This is the name of the Azure Resouce Group containing the
Cosmos DB.

```yaml
Type: String
Parameter Sets: AzureAccount
Aliases: ResourceGroup

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token

This is an array of Token objects. These can be generated by
retrieving a Cosmos DB user account that has had permissions assigned.

```yaml
Type: ContextToken[]
Parameter Sets: Token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: ContextToken[]
Parameter Sets: Emulator
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URI

This is an optional URI to a Cosmos DB emulator.

```yaml
Type: String
Parameter Sets: Emulator
Aliases:

Required: False
Position: Named
Default value: localhost
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
