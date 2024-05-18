---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# Get-CosmosDbAuthorizationHeaderFromContext

## SYNOPSIS

Create a new Authorization Token to be used with in a
Rest API request to Cosmos DB.

## SYNTAX

```powershell
Get-CosmosDbAuthorizationHeaderFromContext [-Key] <SecureString> [[-KeyType] <String>] [[-Method] <String>]
 [[-ResourceType] <String>] [[-ResourceId] <String>] [-Date] <DateTime> [[-TokenVersion] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet is used to create an HTTP request header containing
a master key Authorization Token and the date of the request
to pass in a Rest API request to an Azure Cosmos DB.
The Authorization token that is generated will match the
other parameters in the header of the request that is passed
and can not be used with other requests.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> $dttoken = ConvertTo-CosmosDbTokenDateString -Date (Get-Date)
PS C:\> $header = Get-CosmosDbAuthorizationHeaderFromContext -Key $Key -KeyType master -Method Get -ResourceType 'dbs' -ResourceId 'dbs/mydatabase' -Date ($dttoken)
```

Generate a collection of headers required for Cosmos DB token authorization
using a master key $Key for issuing a 'Get' request on the dbs (database)
'mydatabase'.

## PARAMETERS

### -Key

The key to be used to access this Cosmos DB.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KeyType

The type of key that will be used to access ths Cosmos DB.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method

This is the Rest API method that will be made in the request
this token is being generated for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceType

This is type of resource being accessed in the Cosmos DB.
For example: users, colls

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId

This is the resource Id of the Cosmos DB being accessed.
This is in the format 'dbs/{database}' and must match the
the value in the path of the URI that the request is made
to. This value is case sensitive and must match the case
of the required resource stored in Cosmos DB account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date

This is the DateTime of the request being made.
This must be included in the 'x-ms-date' parameter in
the request header and match what was provided to this
cmdlet.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TokenVersion

This is the version number of the token to generate.
It will default to '1.0'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 1.0
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
