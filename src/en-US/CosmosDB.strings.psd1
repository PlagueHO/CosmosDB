# culture="en-US"
ConvertFrom-StringData -StringData @'
    ImportingLibFileMessage = Importing function library '{0}'.
    FindResourceTokenInContext = Searching context tokens for resource matching '{0}'.
    FoundResourceTokenInContext = {0} context token(s) with resource '{1}' found.
    FoundUnExpiredResourceTokenInContext = Un-expired context token with resource '{0}' and timestamp '{1}' found.
    NotFoundResourceTokenInContext = Context token with resource '{0}' not found.
    NoMatchingUnexpiredResourceTokenInContext = At least one matching context token with resource '{0}' was found, but all are expired.
    CreateAuthorizationToken = Creating authorization token: Method = '{0}', ResourceType = '{1}', ResourceId = '{2}', Date = '{3}'.
    StoredProcedureScriptLogResults = Stored Procedure '{0}' script log results:\n{1}
    ErrorAuthorizationKeyEmpty = The authorization key is empty. It must be passed in the context or a valid token context for the resource being accessed must be supplied.
    ErrorNewCollectionOfferParameterConflict = Both 'OfferType' and 'OfferThroughput' should not be specified when creating a new collection.
    ErrorNewCollectionParitionKeyRequired = A 'PartitionKey' is required when the 'OfferThroughput' is greater than 10000.
    ErrorNewCollectionIncludedPathIndexInvalidDataType = The DataType '{1}' is invalid for the included path index Kind '{0}'. Please use one of: {2}.
    ErrorNewCollectionIncludedPathIndexPrecisionNotSupported = A Precision value should not be provided for the index Kind '{0}'.
    ErrorNewCollectionIndexingPolicyInvalidMode = Automatic must be set to 'False' if Indexing Mode of 'None' is used.
'@
