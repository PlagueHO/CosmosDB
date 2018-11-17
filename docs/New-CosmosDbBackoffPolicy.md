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
New-CosmosDbBackoffPolicy [[-MaxRetries] <Int32>] [[-Method] <String>] [[-Delay] <Int32>] [<CommonParameters>]
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

The default back-off method will use the largest of the two values,
delay and `x-ms-retry-after-ms` each time.

An additive back-off method will add the delay to the value of the
`x-ms-retry-after-ms` header each time.

A linear back-off method will use a delay equal to the delay times
the number of retries.

An exponential back-off method will exponentially increase the delay
with value each retry.

A random back-off method will wait +/- 50% of the delay value each
retry.

Note: If a calculated delay results in a value less than the
`x-ms-retry-after-ms` header value then the `x-ms-retry-after-ms`
value will be used.

## EXAMPLES

### Example 1

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDBBackoffPolicy -MaxRetries 5
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 5 retries
with a delay between them matching the `x-ms-retry-after-ms` header
value returned from Cosmos DB.

### Example 2

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

### Example 3

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDBBackoffPolicy -MaxRetries 10 -Method Default -Delay 100
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 10 retries.
A delay of 100ms will always be used unless it is less than the
`x-ms-retry-after-ms` header.

### Example 4

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 10 -Method Additive -Delay 1000
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 10 retries.
The delay between each retry will be the returned `x-ms-retry-after-ms`
header value plus 1000ms.

### Example 5

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 3 -Method Linear -Delay 500
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 3 retries.
The delay between each retry will wait for 500ms on the first retry,
1000ms on the second retry, 1500ms on final retry.

### Example 6

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 4 -Method Exponential -Delay 1000
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 3 retries.
The delay between each retry will wait for 1000ms on the first retry,
4000ms on the second retry, 9000ms on the 3rd retry and 16000ms on
the final retry.

### Example 7

```powershell
PS C:\> $primaryKey = ConvertTo-SecureString -String 'your master key' -AsPlainText -Force
PS C:\> $backoffPolicy = New-CosmosDbBackoffPolicy -MaxRetries 3 -Method Random -Delay 1000
PS C:\> $cosmosDbContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Key $primaryKey -BackoffPolicy $backoffPolicy
PS C:\> $query = "SELECT * FROM customers c WHERE (c.id = 'user@contoso.com')"
PS C:\> $documents = Get-CosmosDBDocument -Context $cosmosDBContext -CollectionId 'MyNewCollection' -Query $query
```

Creates a CosmosDB context specifying the master key manually. A
Back-off Policy will be applied to the context that allows 3 retries.
The delay adds or subtracts up to 50% of the delay period to the base
delay each time can also be applied. For example, the first delay
might be 850ms, with the second delay being 1424ms and final delay
being 983ms.

## PARAMETERS

### -Delay

This is the number of milliseconds to wait before retrying the
last request. The behavior of this value depends on the method.
See the description of this function for more detail.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 5000
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxRetries

This is the number of times to retry the request if a 429 error
is recieved.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method

This is the back-off method of the policy.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Default, Additive, Linear, Exponential, Random

Required: False
Position: 1
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
