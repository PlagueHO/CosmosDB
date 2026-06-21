# CosmosDB PowerShell Module — Agent Instructions

See `.github/copilot-instructions.md` for code style and patterns.

## Layout

```text
source/
├── Public/<resource-type>/    # Cmdlets: one file per function
├── Private/<resource-type>/   # Internal helpers (mirrors Public)
├── Private/utils/             # Invoke-CosmosDbRequest.ps1 (core REST wrapper)
├── classes/CosmosDB/          # C# types → CosmosDB.dll (netstandard2.0)
├── prefix.ps1                 # Module init (Az imports, type loading)
├── CosmosDB.psd1              # Manifest (auto-updated by build — do not edit version)
├── CosmosDB.psm1              # Generated — do not edit
tests/
├── Unit/CosmosDB.<type>.Tests.ps1
├── Integration/
├── TestHelper/                # Fixtures, Bicep templates, auth setup
docs/                          # PlatyPS markdown → external help XML
output/CosmosDB/<version>/     # Build output (versioned)
```

## Commands

> **Local builds:** GitVersion 6.x outputs INFO lines to stdout, which breaks the
> default `build.ps1` invocation. Use `.build-local.ps1` instead — it wraps
> `gitversion` to strip log noise and remap `NuGetVersionV2` for Sampler compatibility.
> After running unit tests, `CosmosDB.dll` is locked in the current session; subsequent
> builds should be run in a new PowerShell process (for example, restart your `pwsh` session) to avoid file locking.

```powershell
# Bootstrap (first time or after clean)
./build.ps1 -ResolveDependency -Tasks noop

# Build (compile C#, assemble module, generate help)
./.build-local.ps1 -Tasks build

# Unit tests only (no Azure required)
./.build-local.ps1 -Tasks test -PesterScript tests/Unit

# All tests (unit + integration — requires Azure credentials)
./.build-local.ps1 -Tasks test

# Package for publishing
./.build-local.ps1 -Tasks pack
```

**C# classes only:**
```powershell
dotnet build source/classes/CosmosDB/CosmosDB.csproj /p:Configuration=Release
```

## Adding a Cmdlet — Checklist

1. Create `source/Public/<resource-type>/Verb-CosmosDb<Noun>.ps1`
1. Include `Context` and `Account` parameter sets (see existing cmdlets)
1. Call `Invoke-CosmosDbRequest` with correct `-ResourceType` / `-ResourcePath`
1. Add unit test in `tests/Unit/CosmosDB.<resource-type>.Tests.ps1`
1. Add integration test if the cmdlet hits the live API
1. Create/update `docs/Verb-CosmosDb<Noun>.md` (PlatyPS format)
1. Run `./.build-local.ps1 -Tasks build` — must succeed
1. Run `./.build-local.ps1 -Tasks test -PesterScript tests/Unit` — must pass

## CI Pipeline (Azure Pipelines)

- **Build**: `./build.ps1 -ResolveDependency -Tasks pack` on Ubuntu; produces versioned artifact
- **Unit tests**: PS 5.1 + PS 7 matrix on Windows, Ubuntu, macOS
- **Integration tests**: same matrix with live Cosmos DB account
- All test stages **must pass**
- **Code coverage**: ≥ 70% (JaCoCo); build fails if under
- **Deploy**: tags matching `v*` on `main` publish to PSGallery and GitHub Releases

## Conventions

| Concern | Rule |
|---------|------|
| Function naming | `Verb-CosmosDb<Noun>` — approved verbs only |
| File naming | One function per file, filename matches function name |
| Generated files | Never edit `CosmosDB.psm1` or version in `CosmosDB.psd1` |
| Tests | Pester 4.x with `InModuleScope`; one test file per resource type |
| Line endings | LF; newline at end of file; no trailing whitespace |
| Encoding | UTF-8 without BOM |
| Indentation | 4 spaces everywhere (PS, YAML, Markdown) |
| Do not commit | `output/` directory contents |

## Permission Boundaries

- **Do without asking**: edit source/test/doc files, run build and unit tests
- **Ask first**: modify `build.yaml`, `.github/workflows/ci.yml`, `.github/workflows/release.yml`, `RequiredModules.psd1`, or any CI config
- **Never**: commit secrets, push to `main`, run integration tests against live Azure
