# culture="en-US"
ConvertFrom-StringData -StringData @'
    ImportingLibFileMessage = Importing function library '{0}'.
    FindResourceTokenInContext = Searching context tokens for resource matching '{0}'.
    FoundResourceTokenInContext = {0} context token(s) with resource '{1}' found.
    FoundUnExpiredResourceTokenInContext = Un-expired context token with resource '{0}' and timestamp '{1}' found.
    NotFoundResourceTokenInContext = Context token with resource '{0}' not found.
    NoMatchingUnexpiredResourceTokenInContext = At least one matching context token with resource '{0}' was found, but all are expired.
    CreateAuthorizationToken = Creating authorization token: Method = '{0}', ResourceType = '{1}', ResourceId = '{2}', Date = '{3}'.
    GettingAzureCosmosDBAccount = Getting Azure Cosmos DB account '{0}' in resource group '{1}'.
    GettingAzureCosmosDBAccountConnectionString = Getting connection string for Azure Cosmos DB account '{0}' in resource group '{1}'.
    GettingAzureCosmosDBAccountMasterKey = Getting '{2}' for Azure Cosmos DB account '{0}' in resource group '{1}'.
    RegeneratingAzureCosmosDBAccountMasterKey = Regenerating '{2}' for Azure Cosmos DB account '{0}' in resource group '{1}'.
    CreatingAzureCosmosDBAccount = Creating Azure Cosmos DB account '{0}' in resource group '{1}' located in '{2}'.
    UpdatingAzureCosmosDBAccount = Updating Azure Cosmos DB account '{0}' in resource group '{1}'.
    RemovingAzureCosmosDBAccount = Removing Azure Cosmos DB account '{0}' in resource group '{1}'.
    StoredProcedureScriptLogResults = Stored Procedure '{0}' script log results:\n{1}
    RequestChargeResults = Request charge for {0} to '{1}' was {2} RUs.
    CollectionProvisionedThroughputExceededWithBackoffPolicy = The collection has exceeded the provisioned throughput limit but a back-off policy is specified.
    CollectionProvisionedThroughputExceededNoBackoffPolicy = The collection has exceeded the provisioned throughput limit but there is no back-off policy.
    CollectionProvisionedThroughputExceededMaxRetriesHit = The maximum back-off policy retries {0} has been exceeded.
    BackOffPolicyAppliedPolicyDelay = The {0} back-off policy delay {1}ms will be used because it is longer than the requested delay {2}ms.
    BackOffPolicyAppliedRequestedDelay = The requested delay {2}ms will be used because it is longer than the {0} back-off policy delay {1}ms.
    WaitingBackoffPolicyDelay = The collection has exceeded the provisioned throughput limit but retry {0} will be attempted in {1}ms.
    ErrorAuthorizationKeyEmpty = The authorization key is empty. It must be passed in the context or a valid token context for the resource being accessed must be supplied.
    ErrorNewCollectionOfferParameterConflict = Both 'OfferType' and 'OfferThroughput' should not be specified when creating a new collection.
    ErrorNewCollectionParitionKeyRequired = A 'PartitionKey' is required when the 'OfferThroughput' is greater than 10000.
    ErrorNewCollectionIncludedPathIndexInvalidDataType = The DataType '{1}' is invalid for the included path index Kind '{0}'. Please use one of: {2}.
    ErrorNewCollectionIncludedPathIndexPrecisionNotSupported = A Precision value should not be provided for the index Kind '{0}'.
    ErrorNewCollectionIndexingPolicyInvalidMode = Automatic must be set to 'False' if Indexing Mode of 'None' is used.
    ErrorSetCollectionRemoveDefaultTimeToLiveConflict = RemoveDefaultTimeToLive parameter must not be set when DefaultTimeToLive is specified.
    ErrorAccountDoesNotExist = Cosmos DB account '{0}' in resource group '{1}' does not exist.
    ShouldCreateAzureCosmosDBAccount = Create an Azure Cosmos DB account '{0}' in resource group '{1}' located in '{2}'
    ShouldUpdateAzureCosmosDBAccount = Update an Azure Cosmos DB account '{0}' in resource group '{1}'
    ShouldRemoveAzureCosmosDBAccount = Remove the Azure Cosmos DB account '{0}' in resource group '{1}'
    GettingAzureCosmosDBAccountConnectionStringWarning = The Get-CosmosDbAccountConnectionString function does not currently work due to an issue with the Microsoft/DocumentDB provider. The connection strings will not be returned.
    AccountNameInvalid = The Account Name '{0}' is invalid. The name can contain only lowercase letters, numbers and the '-' character, and must be between 3 and 31 characters.
    ResourceGroupNameInvalid = The Resource Group Name '{0}' is invalid. Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis, cannot end in a period and must be 90 characters or less.
    DatabaseIdInvalid = The Database Id '{0}' is invalid. A Database Id must not contain characters '\','/','#','?' or '=', end with a space and must be 255 characters or less.
'@
