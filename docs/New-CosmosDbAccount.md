---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbAccount

## SYNOPSIS

Create a new Cosmos DB account in Azure.

## SYNTAX

```powershell
New-CosmosDbAccount [-Name] <String> [-ResourceGroupName] <String> [-Location] <String>
 [[-LocationRead] <String[]>] [[-DefaultConsistencyLevel] <String>] [[-MaxIntervalInSeconds] <Int32>]
 [[-MaxStalenessPrefix] <Int32>] [[-IpRangeFilter] <String[]>] [[-Capability] <String>] [[-AllowedOrgin] <String[]>]
[-AsJob] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Use this function to create a new Cosmos DB account resource in
Azure.

You must have the Az.Resources PowerShell module installed
and must also be authenticated to Azure. The Resource Group that
the Cosmos DB is created in must also exist.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS'
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region.

### Example 2

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS' -LocationRead 'EastUS'
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region. A second Read Location will be created in
'EastUS'.

### Example 3

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS' -IpRangeFilter @('103.29.31.78/32','103.29.31.79/32')
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region. The Cosmos DB will only be accessible from
the IP addresses '103.29.31.78/32' and '103.29.31.79/32'.

### Example 4

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS' -DefaultConsistencyLevel 'Strong'
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region. The Cosmos DB will be configured to use
a default consistency level of 'Strong'.

### Example 5

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS' -AllowedOrigin @('https://www.contoso.com','https://www.fabrikam.com')
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region. The Cosmos DB will have the CORS allowed
origins set to 'https://www.contoso.com' and 'https://www.fabrikam.com'.

### Example 6

```powershell
PS C:\> New-CosmosDbAccount -Name 'MyCosmosDB' -ResourceGroup 'MyData' -Location 'WestUS' -Capability 'EnableServerless'
```

Create a new Cosmos DB account called 'MyCosmosDB' in an existing
Resource Group caled 'MyData'. The account will be created in the
'WestUS' Azure region. The Cosmos DB will be provisioned in the
Serverless capacity mode.

## PARAMETERS

### -AllowedOrigin

Set Cross-Origin Resource Sharing (CORS) allowed orgin URLs on
the new account. Defaults to '*'.

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

Create the resource in the background. The function will return
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

### -Capability

The capability of the database account.
For more information see https://docs.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts?tabs=json#capability.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: EnableCassandra, EnableTable, EnableGremlin, EnableServerless

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
This is also the region the Cosmos DB account will be created in.

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

The name of the Cosmos DB Account to create.

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

The name of the existing Azure resource group to create the account
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
