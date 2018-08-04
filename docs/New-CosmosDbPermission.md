---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version:
schema: 2.0.0
---

# New-CosmosDbPermission

## SYNOPSIS

Create a new permission for a user in a Cosmos DB database.

## SYNTAX

### Context (Default)

```powershell
New-CosmosDbPermission -Context <Context> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -UserId <String> -Id <String> -Resource <String> [-PermissionMode <String>] [<CommonParameters>]
```

### Account

```powershell
New-CosmosDbPermission -Account <String> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -UserId <String> -Id <String> -Resource <String> [-PermissionMode <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a permission for a user in a Cosmos DB.

## EXAMPLES

### Example 1

```powershell
PS C:\> $collectionId = Get-CosmosDbCollectionResourcePath -Database 'MyDatabase' -Id 'MyNewCollection'
PS C:\> New-CosmosDbPermission -Context $cosmosDbContext -UserId 'MyApplication' -Id 'r_mynewcollection' -Resource $collectionId -PermissionMode Read
```

Create a 'read' permission to the 'MyNewCollection' collection in a database
for the user 'MyApplication'.

## PARAMETERS

### -Context

This is an object containing the context information of the Cosmos DB database
that will be deleted. It should be created by \`New-CosmosDbContext\`.

```yaml
Type: Context
Parameter Sets: Context
Aliases: Connection

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Account

The account name of the Cosmos DB to access.

```yaml
Type: String
Parameter Sets: Account
Aliases:

Required: True
Position: Named
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
Position: Named
Default value: Master
Accept pipeline input: False
Accept wildcard characters: False
```

### -Key

The key to be used to access this Cosmos DB.

```yaml
Type: SecureString
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

### -UserId

This is the id of the user to create the permissions for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

This is the Id of the permission to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resource

This is the full path to the resource to grant permission to the user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PermissionMode

This is the type of the permission to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
