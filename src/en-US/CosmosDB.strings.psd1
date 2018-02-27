# culture="en-US"
ConvertFrom-StringData -StringData @'
    ImportingLibFileMessage = Importing function library '{0}'.
    ErrorNewCollectionOfferParameterConflict = Both 'OfferType' and 'OfferThroughput' should not be specified when creating a new collection.
    ErrorNewCollectionParitionKeyRequired = A 'PartitionKey' is required when the 'OfferThroughput' is greater than 10000.
'@
