---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbBackoffPolicy

## SYNOPSIS

Create a new Backoff Policy that can be added to a Cosmos DB Context to
control the behavior when "Too Many Request" (error code 429) responses
are recieved.

## SYNTAX

```powershell
New-CosmosDbBackoffPolicy [-MaxRetries] <Int32> [-Method] <String> [-Delay] <Int32>
 [<CommonParameters>]
```

## DESCRIPTION

This function creates a new Back-off Policy that can be used to control
the behavior of most Cosmos DB functions when a "Too Many Request"
(error code 429) response is recieved.

If a Back-off Policy is applied to a context that is used with a Cosmos DB
function and an error code 429 is recieved then a Back-off Policy can
be used to control whether or not to retry the request.

If no Back-off Policy is defined then the 429 error is simply returned to
the caller.

## EXAMPLES

### Example 1

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDBBackoffPolicy -MaxRetries 5 -Delay 2000
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 5 retries
with a delay of 2 seconds between them.

## PARAMETERS

### -MaxRetries

This is the number of times to retry the request if a 429 error
is recieved.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method

This is the back-off method of the policy.

A linear back-off method will always wait the same amount of time
between retried.

An exponential back-off method will double the delay value each
retry.

A random back-off method will wait +/- 50% of the delay value each
retry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: Linear
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delay

This is the number of milliseconds to wait before retrying the
last request.

If a linear back-off method is used then this is the exact
number of milliseconds to wait between retries.

If an exponential back-off method is used then this is the base
delay to use for the first failure. Further failures will double
this value.

If a random back-off method is used then the delay will
be this value +/- 50%.

If the request returned a 'x-ms-retry-after-ms' header then the
greater of the 'x-ms-retry-after-ms' value and the current value
of the delay will be used.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 5000
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None


## OUTPUTS

### System.Management.Automation.PSCustomObject


## NOTES

## RELATED LINKS
