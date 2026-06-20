# CosmosDB PowerShell Module — Copilot Instructions

See `AGENTS.md` for directory layout, build commands, and CI pipeline.
See `.github/instructions/powershell.instructions.md` for general PowerShell conventions.
See `.github/instructions/powershell-pester-5.instructions.md` for Pester testing patterns.

## Purpose

Cross-platform PowerShell module wrapping the Azure Cosmos DB REST API.
Supports RBAC (Entra ID) and master-key authentication. Targets PS 5.1+ and PS 7+.
Built with Sampler/ModuleBuilder; C# types in `source/classes/CosmosDB/`.

## Code Style

- 4-space indentation everywhere (PowerShell, YAML, Markdown, C#)
- Single quotes for literal strings; double quotes only when interpolating variables
- Opening brace on its **own line** (Allman style) — except hashtables/scriptblocks assigned to variables
- No trailing whitespace; LF line endings; newline at end of file
- UTF-8 without BOM
- Use full cmdlet names — no aliases (`Get-ChildItem` not `gci`, `Where-Object` not `?`)
- Use splatting for calls with 3+ parameters

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Public functions | `Verb-CosmosDb<Noun>` (approved verbs) | `Get-CosmosDbDocument` |
| Source files | One function per file, filename = function name | `Get-CosmosDbDocument.ps1` |
| Parameters | PascalCase, `[Parameter()]` attribute required | `$CollectionId` |
| Local variables | camelCase | `$resourcePath` |
| Script-scope vars | `$script:` prefix | `$script:testAccount` |
| Test files | `CosmosDB.<resource-type>.Tests.ps1` | `CosmosDB.documents.Tests.ps1` |

## PowerShell Patterns

- Every public cmdlet must define both `Context` and `Account` parameter sets:

```powershell
[Parameter(Mandatory = $true, ParameterSetName = 'Context')]
[CosmosDb.Context] $Context,

[Parameter(Mandatory = $true, ParameterSetName = 'Account')]
[System.String] $Account,
```

- Route all REST calls through `Invoke-CosmosDbRequest` — never call `Invoke-RestMethod` directly
- Keys and tokens **must** be `[System.Security.SecureString]` — never plain-text strings
- Use `[ValidateNotNullOrEmpty()]` on all non-mandatory string parameters
- Use `[ValidateScript()]` with `Assert-CosmosDb*Valid` helpers for IDs and names
- Include `[CmdletBinding()]` and `[OutputType()]` on every function
- Mandatory parameters use `[Parameter(Mandatory = $true)]`

## Testing

- Pester 4.x; tests wrapped in `InModuleScope $ProjectName { ... }`
- One test file per resource type in `tests/Unit/`
- Mock `Invoke-CosmosDbRequest` to isolate from REST calls
- Use `$script:` variables for shared test fixtures (accounts, keys, contexts)
- `ConvertTo-SecureString -AsPlainText -Force` is acceptable **only** in test files
- Use `.build-local.ps1` for all local builds and test runs (see `AGENTS.md`)

## Security

- Never store or log master keys in plain text — always `SecureString`
- Prefer Entra ID authentication over master keys in examples and docs
- `Invoke-CosmosDbRequest` strips auth headers from error responses — do not bypass this
- Do not commit Azure credentials, connection strings, or tokens
- Do not use `Invoke-Expression` — use direct cmdlet calls or `& operator`
