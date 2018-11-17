---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbContextToken

## SYNOPSIS

Create a new Context Token that can be used to create a resource
context.

## SYNTAX

```powershell
New-CosmosDbContextToken [-Resource] <String> [-TimeStamp] <DateTime> [[-TokenExpiry] <Int32>]
 [-Token] <SecureString> [<CommonParameters>]
```

## DESCRIPTION

This function creates a new Context Token that can be used to create
a context containing resource level access tokens. This is created
from a token retrieved from a Cosmos DB permission for a user.

## EXAMPLES

### Example 1

```powershell
PS C:\> $collection = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyAccountCollection'
PS C:\> $permission = Get-CosmosDBPermission -Context $context -UserId $userId -Id 'MyAccountCollection'
PS C:\> $token = New-CosmosDBContextToken -Resource $collection -TimeStamp $permission.TimeStamp -Token $permission.Token
PS C:\> $tokenContext = New-CosmosDbContext -Account 'MyAzureCosmosDB' -Database 'MyDatabase' -Token $token
```

This example gets a user permission for the collection MyAccountCollection.
collection. The context token is then used to create a context that can only
be used to grant access to the MyAccountCollection.

## PARAMETERS

### -Resource

This is the path to the resource that this Context Token will grant
access to.

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

### -TimeStamp

This is the timestamp that this context token was issued.

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

### -Token

This is the token retrieved from a Cosmos DB user permission for
the specified Cosmos DB resource.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TokenExpiry

This is the number of seconds the token will be valid for. It is
added to the TimeStamp parameter to calculate the expected expiration
date/time of the token.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3600
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
