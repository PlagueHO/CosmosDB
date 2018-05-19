# culture="en-US"
ConvertFrom-StringData -StringData @'
    ImportingLibFileMessage = Importing function library '{0}'.
    FindResourceTokenInContext = Searching context tokens for resource matching '{0}'.
    FoundResourceTokenInContext = Context token with resource '{0}' found with timestamp '{1}'.
    NotFoundResourceTokenInContext = Context token with resource '{0}' not found.
    CreateAuthorizationToken = Creating authorization token: Method = '{0}', ResourceType = '{1}', ResourceId = '{2}', Date = '{3}'.
    ErrorAuthorizationKeyEmpty = The authorization key is empty. It must be passed in the context or a valid token context for the resource being accessed must be supplied.
    ErrorNewCollectionOfferParameterConflict = Both 'OfferType' and 'OfferThroughput' should not be specified when creating a new collection.
    ErrorNewCollectionParitionKeyRequired = A 'PartitionKey' is required when the 'OfferThroughput' is greater than 10000.
'@
