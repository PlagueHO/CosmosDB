---
external help file: CosmosDB-help.xml
Module Name: CosmosDB
online version: 
schema: 2.0.0
---

# New-CosmosDbDocument

## SYNOPSIS
Create a new document for a collection in a CosmosDB database.

## SYNTAX

### Connection (Default)
```
New-CosmosDbDocument -Connection <PSObject> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -CollectionId <String> -DocumentBody <String> [-IndexingDirective <String>]
```

### Account
```
New-CosmosDbDocument -Account <String> [-KeyType <String>] [-Key <SecureString>] [-Database <String>]
 -CollectionId <String> -DocumentBody <String> [-IndexingDirective <String>]
```

## DESCRIPTION
This cmdlet will create a document for a collection in a CosmosDB.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Connection
This is an object containing the connection information of
the CosmosDB database that will be deleted.
It should be created
by \`New-CosmosDbConnection\`.

```yaml
Type: PSObject
Parameter Sets: Connection
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Account
The account name of the CosmosDB to access.

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
The type of key that will be used to access ths CosmosDB.

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
The key to be used to access this CosmosDB.

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
The name of the database to access in the CosmosDB account.

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

### -CollectionId
This is the Id of the collection to create the document for.

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

### -DocumentBody
This is the body of the document.
It must be formatted as
a JSON string and contain the Id value of the document to
create.

The document body must contain an id field.

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

### -IndexingDirective
Include adds the document to the index.
Exclude omits the
document from indexing.
The default for indexing behavior is
determined by the automatic propertyâ€™s value in the indexing
policy for the collection.

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

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

