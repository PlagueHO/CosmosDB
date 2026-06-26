# Release Process: CosmosDB PowerShell Module

**Last Updated:** 2026-06-26
**Owner:** PlagueHO Team

## Overview

Releases are driven entirely by pushing an annotated git tag matching `v*` to
`origin`. The tag triggers the `.github/workflows/release.yml` workflow, which
builds, packages, publishes to PowerShell Gallery, and creates a GitHub Release.

> **Critical:** GitHub Actions uses the workflow file from the **commit the tag
> points to**, not from the current HEAD of `main`. The tag must be placed on a
> commit that already contains the current `release.yml`.

---

## Version Numbering

Versioning follows [Semantic Versioning 2.0.0](https://semver.org/). The version
is calculated by GitVersion 6.x from the git history and tags.

| Change type | Version bump | CHANGELOG keyword |
|---|---|---|
| Breaking change (removed/renamed API, required param added) | Major (`X.0.0`) | `BREAKING CHANGE` |
| New feature, new cmdlet, new parameter set | Minor (`x.Y.0`) | `add`, `feature`, `minor` |
| Bug fix, documentation, chore | Patch (`x.y.Z`) | `fix`, `patch` |

The `GitVersion.yml` `next-version` field (`3.0.0`) is only used as a fallback
when no tags exist. Once a `vX.Y.Z` tag is present, all version calculations
derive from it.

---

## Pre-Release Checklist

Before creating the tag, complete all of these steps on the `main` branch.

### 1. Ensure CI is green

All CI jobs (build, unit tests, integration tests) must pass on the commit you
intend to tag. The release workflow does **not** run tests.

### 2. Update `CHANGELOG.md`

The Sampler `Create_changelog_release_output` build task extracts release notes
by matching the `[X.Y.Z]` heading in the changelog to the GitVersion-calculated
version. If the heading is still `[Unreleased]` when the tag is built, the
published release will have **empty release notes**.

```markdown
## [Unreleased]          ← rename this to the new version

### Changed
...
```

becomes:

```markdown
## [Unreleased]          ← add a new empty section above

## [7.0.0] - 2026-06-26  ← renamed from [Unreleased]

### Changed
...
```

### 3. Commit and push to `main`

```powershell
git add CHANGELOG.md
git commit -m "Release vX.Y.Z"
git push origin main
```

---

## Creating the Release Tag

Run these commands after the pre-release commit is on `main` and CI is green.

```powershell
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

Pushing the tag immediately triggers the release workflow.

---

## Release Workflow (`release.yml`)

The workflow runs on `ubuntu-latest` in the `test` environment.

> If the `test` environment has **required reviewers** configured in the GitHub
> repository settings, the workflow pauses for manual approval before any step
> executes.

### Steps

| Step | What it does |
|---|---|
| Checkout | Full history (`fetch-depth: 0`) — required by GitVersion |
| Set up .NET SDK | Installs .NET 8 for GitVersion and C# class compilation |
| Install GitVersion | `dotnet tool install GitVersion.Tool --version 6.*` |
| Calculate module version | Runs `dotnet-gitversion`, filters INFO/WARN/VERBOSE/DEBUG log lines from stdout, extracts `SemVer` and `BranchName`, writes both to `$GITHUB_ENV` as `ModuleVersion` and `BranchName` |
| Build and package | `./build.ps1 -Tasks pack` with `ModuleVersion` and `BranchName` env vars set; produces `output/CosmosDB.X.Y.Z.nupkg` |
| Sign in to Azure (OIDC) | Federated identity login — required for any Az cmdlets used during publish |
| Publish to PowerShell Gallery | `./build.ps1 -Tasks publish` → Sampler task `Publish_Module_To_gallery`; uses `NUGET_API_KEY` / `NuGetApiKey` env vars (both set from `secrets.PSGALLERY_API_KEY`) |
| Create GitHub Release | `softprops/action-gh-release@v2` — creates/updates the release for the tag, uploads `output/CosmosDB*.nupkg`, generates release notes |

### Required secrets

| Secret name | Used for |
|---|---|
| `PSGALLERY_API_KEY` | PowerShell Gallery NuGet API key |
| `AZURE_CLIENT_ID` | OIDC federated identity client ID |
| `AZURE_TENANT_ID` | Azure tenant for OIDC login |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription for OIDC login |

### Sampler publish conditions

Sampler's `Publish_Module_To_gallery` task only runs when **both** are true:

- `$Env:BranchName` equals `main` (or `master`)
- `$Env:ModuleVersion` contains no pre-release suffix (no `-`)

This is why the `Calculate module version` step explicitly exports `BranchName`
to `$GITHUB_ENV` and why GitVersion must correctly compute a clean version from
the tag.

---

## If the Release Workflow Fails

### Wrong version (`0.0.1`) or tasks skipped

**Cause:** GitVersion 6.x emits `INFO [...]` lines to stdout that corrupt the
JSON output when parsed naively. The `Calculate module version` step filters
these with `Where-Object { $_ -notmatch '^\s*(INFO|WARN|VERBOSE|DEBUG) \[' }`.
If this step is absent or the tag points to a commit where `release.yml` did not
yet contain this fix, the version falls back to `0.0.1` and Sampler skips the
publish tasks because the version has no match.

**Fix:** Move the tag to a commit that has the correct `release.yml`, then
re-trigger (see below).

### Recovering from a broken release

1. Delete the GitHub Release for the tag via the GitHub UI
   (Edit → Delete release). This removes any incorrectly uploaded assets.
2. Delete the tag locally and remotely:

   ```powershell
   git tag -d vX.Y.Z
   git push origin --delete vX.Y.Z
   ```

3. Ensure the fixes are committed and pushed to `main`.
4. Recreate the tag at the current HEAD:

   ```powershell
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

The workflow will fire again using the workflow file from the new tag commit.

> **Note:** Re-running a failed workflow from the GitHub Actions UI will **not**
> pick up changes to `release.yml`; it always uses the workflow file from the
> original triggering commit.

---

## Post-Release Verification

After the workflow completes:

- [ ] GitHub Release at `https://github.com/PlagueHO/CosmosDB/releases/tag/vX.Y.Z`
      contains `CosmosDB.X.Y.Z.nupkg` (not `CosmosDB.0.0.1.nupkg` or Az.* packages)
- [ ] Release notes reflect the `[X.Y.Z]` section from `CHANGELOG.md`
- [ ] Module is visible on PowerShell Gallery:
      `Find-Module -Name CosmosDB -RequiredVersion X.Y.Z`
