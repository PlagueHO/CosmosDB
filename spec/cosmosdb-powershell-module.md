# Specification: CosmosDB PowerShell Module

**Version:** 1.0
**Last Updated:** 2025-05-31
**Owner:** PlagueHO Team

## 1. Purpose & Scope

This specification defines the requirements, constraints, and interfaces for the
"CosmosDB PowerShell Module", a cross-platform tool providing PowerShell cmdlets
to manage and interact with Azure Cosmos DB accounts, databases, collections,
documents, and related entities using REST APIs, RBAC, and token-based authentication.
The audience includes PowerShell developers, DevOps engineers, and automation
specialists.

Assumptions:

- Execution on PowerShell 5.x, PowerShell 7.0+ (Windows, macOS, Linux).
- Azure subscription and appropriate permissions exist.
- Familiarity with Cosmos DB concepts and Azure CLI/PowerShell.

## 2. Definitions

- **Cosmos DB**: Azure’s globally distributed, multi-model NoSQL database service.
- **RBAC**: Role-Based Access Control for Azure resources.
- **RU/s**: Request Units per second, Cosmos DB throughput unit.
- **Context Object**: A `CosmosDbContext` PowerShell object encapsulating
  endpoint, authentication token/key, and default settings.
- **Cmdlet**: A PowerShell command in Verb-Noun format.

## 3. Requirements, Constraints & Guidelines

- Requirement 1: Support cmdlets for Accounts, Databases, Collections, Documents,
  Offers, Permissions, Stored Procedures, Triggers, User Defined Functions, and Users.
- Requirement 2: Authenticate via Entra ID token (preferred) or master keys/resource
  tokens.
- Requirement 3: Run on PowerShell 7.0+; deprecate PowerShell 5.x.
- Constraint 1: Not a replacement for Az.CosmosDB; focuses on document-level
  operations and RBAC.
- Constraint 2: All cmdlets must include comment-based help for parameters and examples.
- Guideline 1: Follow PowerShell best practices (Verb-Noun, named parameters,
  PascalCase functions, camelCase locals).
- Guideline 2: Break large logic into private helper functions.
- Guideline 3: Use Pester 4.x for unit and integration tests; enforce ≥80% coverage.
- Pattern: `New-CosmosDb<Entity>`, `Get-CosmosDb<Entity>`, `Set-CosmosDb<Entity>`,
  `Remove-CosmosDb<Entity>`.

## 4. Interfaces & Data Contracts

Exampless of cmdlets and their parameters:

| Cmdlet                                | Parameters                              | Returns                   |
|---------------------------------------|-----------------------------------------|---------------------------|
| New-CosmosDbContext                   | -Account<br>-Database<br>-Key<br>-EntraIdToken<br>-AutoGenerateEntraIdToken | `CosmosDbContext` object  |
| Get-CosmosDbCollection                | -Context<br>-Id<br>-MaxItemCount<br>-ContinuationToken | `PSObject[]` of collections |
| New-CosmosDbDocument                  | -Context<br>-CollectionId<br>-DocumentBody<br>-PartitionKey | `PSObject` document       |
| Set-CosmosDbCollection (and others)   | -Context<br>-Id<br>-[Entity-specific]   | `PSObject` updated entity |

```powershell
# Example: Create a document
$doc = @{ id = [guid]::NewGuid().ToString(); content = 'Hello' } | ConvertTo-Json
New-CosmosDbDocument -Context $ctx -CollectionId 'Items' -DocumentBody $doc -PartitionKey $doc.id
```

## 5. Rationale & Context

The module addresses a gap in the Az.CosmosDB module by providing document-level
CRUD operations using REST APIs with RBAC and tokens. It ensures cross-platform
compatibility, maintainability, and testability. Breaking cmdlet logic into smaller
functions improves readability and easier testing.

## 6. Examples & Edge Cases

```powershell
# Example: Retrieve first 5 items with continuation
$header = $null
$items = Get-CosmosDbDocument -Context $ctx -CollectionId 'Items' -MaxItemCount 5 -ResponseHeader ([ref] $header)
$token = Get-CosmosDbContinuationToken -ResponseHeader $header

# Edge Case: Missing partition key
# Should throw a descriptive error when no PartitionKey is provided for
# partitioned collections.
```

## 7. Validation Criteria

- All cmdlets have comment-based help with Synopsis, Parameters, Examples.
- Pester 4.x tests pass with ≥80% coverage.
- PSScriptAnalyzer settings enforce consistent style (`PSScriptAnalyzerSettings.psd1`).
- Integration tests against Cosmos DB emulator succeed.
- Error messages are clear and non-ambiguous.

## 8. Related Specifications / Further Reading

- [docs/CosmosDB.md](docs/CosmosDB.md)
- [Azure Cosmos DB REST API](https://learn.microsoft.com/rest/api/cosmos-db/)
