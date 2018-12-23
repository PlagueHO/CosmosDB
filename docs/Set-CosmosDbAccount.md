---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Set-CosmosDbAccount

## SYNOPSIS

Update the properties of an existing Azure Cosmos DB account.

## SYNTAX

```powershell
Set-CosmosDbAccount [-Name] <String> [-ResourceGroupName] <String> [[-Location] <String>]
 [[-LocationRead] <String[]>] [[-DefaultConsistencyLevel] <String>] [[-MaxIntervalInSeconds] <Int32>]
 [[-MaxStalenessPrefix] <Int32>] [[-IpRangeFilter] <String[]>]  [[-AllowedOrigin] <String[]>]
 [-AsJob] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

This function will update an existing Azure Cosmos DB account
properties to match the settings provided. If a Cosmos DB property
is not provided then the propery will be left at the current value.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -DefaultConsistencyLevel 'Strong'
```

Update an existing Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The Cosmos DB account will have a new
default consistency level set to 'Strong'.

### Example 2

```powershell
PS C:\> Set-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -IpRangeFilter @('103.29.31.78/32','103.29.31.79/32')
```

Update an existing Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The Cosmos DB will only be accessible from
the IP addresses '103.29.31.78/32' and '103.29.31.79/32'.

### Example 3

```powershell
PS C:\> Set-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -AllowedOrigin @('https://www.contoso.com','https://www.fabrikam.com')
```

Update an existing Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The Cosmos DB will have the CORS allowed origins
set to 'https://www.contoso.com' and 'https://www.fabrikam.com'.

### Example 4

```powershell
PS C:\> Set-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -AllowedOrigin ''
```

Update an existing Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The Cosmos DB will have the CORS allowed
origins setting removed.

## PARAMETERS

### -AllowedOrigin

Update Cross-Origin Resource Sharing (CORS) allowed orgin URLs on
the existing account.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsJob

Update the resource in the background. The function will return
immediately with a Job object that can be used to query the state
of the job.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultConsistencyLevel

The default consistency level of the Azure Cosmos DB account.
For more information see https://docs.microsoft.com/en-us/azure/cosmos-db/consistency-levels.

If not specified th value 'Session' will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Eventual, Strong, Session, BoundedStaleness

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IpRangeFilter

Specifies the set of IP addresses or IP address ranges in CIDR
form to be included as the allowed list of client IPs for a given
database account.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location

The location name of the write region of the database account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocationRead

The location name(s) of the read region of the database account.
More than one can be specified. The order of the locations in the
array affect the failover priority.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxIntervalInSeconds

When used with Bounded Staleness consistency, this value represents
the time amount of staleness (in seconds) tolerated. Accepted range
for this value is 1 - 100. This value should only be set when the
DefaultConsistencyLevel is BoundedStaleness.

If not specified th value 5 will be used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxStalenessPrefix

When used with Bounded Staleness consistency, this value represents
the number of stale requests tolerated. Accepted range for this value
is 1 - 2,147,483,647. This value should only be set when the
DefaultConsistencyLevel is BoundedStaleness.

If not specified th value 100 will be used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the Cosmos DB Account to update.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName

The name of the existing Azure resource group to update the account
in.

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
