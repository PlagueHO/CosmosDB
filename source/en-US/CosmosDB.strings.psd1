# culture="en-US"
ConvertFrom-StringData -StringData @'
    LoadingTypesFromDll = Loading Types from DLL '{0}'.
    LoadingTypesFromCS = Loading Types from CS file '{0}'.
    ImportingLibFileMessage = Importing function library '{0}'.
    FindResourceTokenInContext = Searching context tokens for resource matching '{0}'.
    FoundResourceTokenInContext = {0} context token(s) with resource '{1}' found.
    FoundUnExpiredResourceTokenInContext = Un-expired context token with resource '{0}' and timestamp '{1}' found.
    NotFoundResourceTokenInContext = Context token with resource '{0}' not found.
    NoMatchingUnexpiredResourceTokenInContext = At least one matching context token with resource '{0}' was found, but all are expired.
    NoResourceTokensInContext = Context does not contain any resource tokens.
    CreateAuthorizationToken = Creating authorization token: Method = '{0}', ResourceType = '{1}', ResourceId = '{2}', Date = '{3}'.
    GettingAzureCosmosDBAccount = Getting Azure Cosmos DB account '{0}' in resource group '{1}'.
    GettingAzureCosmosDBAccountConnectionString = Getting '{2}' connection string for Azure Cosmos DB account '{0}' in resource group '{1}'.
    GettingAzureCosmosDBAccountMasterKey = Getting '{2}' for Azure Cosmos DB account '{0}' in resource group '{1}'.
    RegeneratingAzureCosmosDBAccountMasterKey = Regenerating '{2}' for Azure Cosmos DB account '{0}' in resource group '{1}'.
    CreatingAzureCosmosDBAccount = Creating Azure Cosmos DB account '{0}' in resource group '{1}' located in '{2}'.
    UpdatingAzureCosmosDBAccount = Updating Azure Cosmos DB account '{0}' in resource group '{1}'.
    RemovingAzureCosmosDBAccount = Removing Azure Cosmos DB account '{0}' in resource group '{1}'.
    StoredProcedureScriptLogResults = Stored Procedure '{0}' script log results:\n{1}
    RequestChargeResults = Request charge for {0} to '{1}' was {2} RUs.
    NonPartitionedCollectionWarning = It is not recommended to create a collection without a partition key. It may result in reduced performance and increased cost. This functionality is included for backwards compatibility only and will be removed in a future version.
    CollectionProvisionedThroughputExceededWithBackoffPolicy = The collection has exceeded the provisioned throughput limit but a back-off policy is specified.
    CollectionProvisionedThroughputExceededNoBackoffPolicy = The collection has exceeded the provisioned throughput limit but there is no back-off policy.
    CollectionProvisionedThroughputExceededMaxRetriesHit = The maximum back-off policy retries {0} has been exceeded.
    BackOffPolicyAppliedPolicyDelay = The {0} back-off policy delay {1}ms will be used because it is longer than the requested delay {2}ms.
    BackOffPolicyAppliedRequestedDelay = The requested delay {2}ms will be used because it is longer than the {0} back-off policy delay {1}ms.
    WaitingBackoffPolicyDelay = The collection has exceeded the provisioned throughput limit but retry {0} will be attempted in {1}ms.
    ErrorAuthorizationKeyEmpty = The authorization key is empty. It must be passed in the context or a valid token context for the resource being accessed must be supplied.
    WarningNewCollectionOfferTypeDeprecated = The 'OfferType' parameter is a legacy parameter and is only supported for backwards compatibility and may be removed in future. It is recommended to use 'OfferThroughput' or 'AutopilotThroughput' instead.
    ErrorNewCollectionOfferParameterConflict = Only one of 'OfferType', OfferThroughput' or 'AutoscaleThroughput' should be specified when creating a new collection.
    ErrorNewCollectionParitionKeyOfferRequired = A 'PartitionKey' is required when the 'OfferThroughput' is greater than 10000.
    ErrorNewCollectionParitionKeyAutoscaleRequired = A 'PartitionKey' is required when the 'AutoscaleThroughput' is used.
    ErrorNewCollectionIncludedPathIndexInvalidDataType = The DataType '{1}' is invalid for the included path index Kind '{0}'. Please use one of: {2}.
    ErrorNewCollectionIncludedPathIndexPrecisionNotSupported = A Precision value should not be provided for the index Kind '{0}'.
    WarningNewCollectionIncludedPathIndexHashDeprecated = The 'Hash' index Kind has been deprecated. Default String and Number 'Range' index Kinds will be used instead. The 'Hash' index Kind will be removed in a future breaking release. See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-kind.
    WarningNewCollectionIncludedPathIndexPrecisionDeprecated = The index 'Precision' has been deprecated. The maximum precision of -1 will be used. The 'Precision' parameter will be removed in a future breaking release. See https://docs.microsoft.com/en-us/azure/cosmos-db/index-types#index-precision.
    ErrorNewCollectionIndexingPolicyInvalidMode = Automatic must be set to 'False' if Indexing Mode of 'None' is used.
    ErrorSetCollectionRemoveDefaultTimeToLiveConflict = RemoveDefaultTimeToLive parameter must not be set when DefaultTimeToLive is specified.
    ErrorAccountDoesNotExist = Cosmos DB account '{0}' in resource group '{1}' does not exist.
    ShouldCreateAzureCosmosDBContext = Create an Azure Cosmos DB context for accessing account '{0}' database '{1}' on URI '{2}'
    ShouldCreateAzureCosmosDBAccount = Create an Azure Cosmos DB account '{0}' in resource group '{1}' located in '{2}'
    ShouldUpdateAzureCosmosDBAccount = Update an Azure Cosmos DB account '{0}' in resource group '{1}'
    ShouldRemoveAzureCosmosDBAccount = Remove the Azure Cosmos DB account '{0}' in resource group '{1}'
    ShouldCreateAzureCosmosDBAccountMasterKey = Create a new Azure Cosmos DB account '{0}' '{2}' in resource group '{1}'
    AccountNameInvalid = The Account Name '{0}' is invalid. The name can contain only lowercase letters, numbers and the '-' character, and must be between 3 and 50 characters.
    ResourceGroupNameInvalid = The Resource Group Name '{0}' is invalid. Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis, cannot end in a period and must be 90 characters or less.
    AttachmentIdInvalid = The Attachment Id '{0}' is invalid. An Attachment Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    CollectionIdInvalid = The Collection Id '{0}' is invalid. A Collection Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    DatabaseIdInvalid = The Database Id '{0}' is invalid. A Database Id must not contain characters '\','/','#','?' or '=', end with a space or be longer than 255 characters.
    DocumentIdInvalid = The Document Id '{0}' is invalid. A Document Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    PermissionIdInvalid = The Permission Id '{0}' is invalid. A Permission Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    StoredProcedureIdInvalid = The Stored Procedure Id '{0}' is invalid. A Stored Procedure Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    TriggerIdInvalid = The Trigger Id '{0}' is invalid. A Trigger Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    UserDefinedFunctionIdInvalid = The User Defined Function Id '{0}' is invalid. A User Defined Function Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    UserIdInvalid = The User Id '{0}' is invalid. A User Id must not contain characters '\','/','#' or '?', end with a space or be longer than 255 characters.
    ErrorPartitionKeyUnsupportedType = The partition key '{0}' uses an unsupported type '{1}'. Partition keys must be be defined in one of the types: String, Int16, Int32 or Int64.
    ResponseHeaderContinuationTokenMissingOrEmpty = The Continuation Token ('x-ms-continuation' attribute) is missing or empty in the Response Header.
    DeprecateContextPortWarning = The Port parameter may be deprecated at a later date in favor of specifying it in the Uri parameter, e.g. https:\\cosmosdbemulator.local:9081. It is recommended to use that method instead of specifying the port parameter to reduce possible impact when the Port parameter is deprecated.
    NotLoggedInToCustomCloudException = The Azure PowerShell cmdlets are not currently logged into an Azure sovereign cloud. Please authenticate to your Azure sovereign cloud using Connect-AzAccount.
    ErrorNewDatabaseThroughputParameterConflict = Both 'OfferThroughput' and 'AutoscaleThroughput' should not be specified when creating a new database.
    DeprecateAttachmentWarning = Attachments are a legacy feature. Their support is scoped to offer continued functionality if you are already using this feature. See https://aka.ms/cosmosdb-attachments for more information.
    ErrorConvertingDocumentJsonToObject = An error occured converting the document information returned from Cosmsos DB into an object. This might be caused by the document including keys with same name but differing in case. Include the -ReturnJson parameter to return these as JSON instead.
    ErrorTooManyRequests = The server returned a '429 Too Many Requests' error. This is likely due to the client making too many requests to the server. Please retry your request.
    ErrorTooManyRequestsWithNoRetryAfter = The server returned a '429 Too Many Requests' error, but the did not include an 'x-ms-retry-after-ms' header in the response. A retry delay of 0ms will be used.
'@
