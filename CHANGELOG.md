# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed

- Remove AppVeyor CI pipeline - fixes [Issue #329](https://github.com/PlagueHO/CosmosDB/issues/329).

### Changed

- Restructure Azure Pipeline:
  - Add testing on Windows Server 2019 and separate module build process.
  - Convert to multi stage pipeline.

### Fixed

- Fix default culture case to fix error on module load in PS7
  on Ubuntu 18.04 - fixes [Issue #332](https://github.com/PlagueHO/CosmosDB/issues/332).

## [3.5.2.487] - 2020-03-14

### Changed

- Update `BuildHelpers` to version 2.0.11.
- Update `Psake` to version 4.9.0.
- Update `Pester` to version 4.10.1.
- Update `PSScriptAnalyzer` to version 1.18.3.
- Change Azure Pipeline Linux build to test PowerShell Core 6.2.3-1.
- Change TravisCI Linux build to test PowerShell Core 6.2.3-1.
- Change TravisCI MacOS build to test PowerShell Core 6.2.3-1.
- Add PowerShell 7 test to Azure Pipeline - fixes [Issue #325](https://github.com/PlagueHO/CosmosDB/issues/325).
- Fix bug converting Secure String in PowerShell 7 on Linux - fixes [Issue #323](https://github.com/PlagueHO/CosmosDB/issues/323).
- Fix issue in Azure Pipeline in MacOS build job - fixes [Issue #326](https://github.com/PlagueHO/CosmosDB/issues/326).
- Remove TravisCI Pipeline - fixes [Issue #327](https://github.com/PlagueHO/CosmosDB/issues/327).
