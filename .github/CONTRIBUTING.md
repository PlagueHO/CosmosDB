# Contributing

If you'd like to contribute to this project, there are several different methods:

- Submit a [Pull Request](https://www.github.com/PlagueHO/CosmosDB/pulls) against the GitHub repository, containing:
  - Bug fixes
  - Enhancements
  - New sample Labs
  - DSC library configurations
  - Documentation enhancements
  - Continuous integration & deployment enhancements
  - Unit tests
- Perform user testing and validation, and report bugs on the [Issue Tracker](https://www.github.com/PlagueHO/CosmosDB/issues)
- Raise awareness about the project through [Twitter](https://twitter.com/#PowerShell), [Facebook](https://facebook.com), and other social media platforms

Before working on any enhancement, submit an Issue describing the proposed enhancement. Someone may already be working on the same thing. It also allows other contributors to comment on the proposal.

Alternately, feel free to post on the [CosmosDB PowerShell Module Gitter Chat at https://gitter.im/PlagueHO/CosmosDB](https://gitter.im/PlagueHO/CosmosDB). This is also a great place to just say Hi, ask any questions you might have or get help.

If you're new to Git revision control, and the GitHub service, it's suggested that you learn about some basic Git fundamentals, and take an overview of the GitHub service offerings.

## Style guidelines

Different software developers have different styles. If you're interested in
contributing to this project, please review the [Style Guidelines](/STYLEGUIDELINES.md).
While these guidelines aren't necessarily "set in stone," they should help guide
the essence of the project, to ensure quality, user satisfaction (*delight*, even),
and success.

## Project Structure

- The module manifest (`.psd1` file) must explicitly denote which functions are
  being exported. Wildcards are not allowed.
- All functions should exist in individual files under `/CosmosDB/Libs/` in the
  folder related to the purpose of the function.
- Use markdown-based help inside the `/docs` folder which can be automatically generated
  by using the [PlatyPS PowerShell Module](https://github.com/PowerShell/platyPS):

  ```powershell
  Import-Module -Name .\src\CosmosDB.psd1
  New-MarkdownHelp -Module CosmosDB -OutputFolder .\docs\
  ```

- All functions must declare the `[CmdletBinding()]` attribute.

## Lifecycle of a pull request

- **Always create pull requests to the `dev` branch of the repository**.

For more information, learn about our [branch structure](#branch-structure).

![Github-PR-dev.png](Images/Github-PR-dev.png)

- Add meaningful title of the PR describing what change you want to check in. Don't simply put: "Fixes issue #5".
  Better example is: "Added All parameter to Get-CosmosDbDatabase - Fixes #5".

- When you create a pull request, fill out the description with a summary of what's included in your changes.
  If the changes are related to an existing GitHub issue, please reference the issue in pull request title or description (e.g. ```Closes #11```). See [this](https://help.github.com/articles/closing-issues-via-commit-messages/) for more details.

- Include an update in the [/CHANGELOG.md](/CHANGELOG.md) file in your pull request to reflect changes for future versions changelog. Put them in `Unreleased` section (create one if doesn't exist). This would simplify the release process for Maintainers. Example:

```text
## Unreleased

- Added support for ...
```

Please use past tense when describing your changes:

- Instead of "Adding support for Windows Server 2012 R2", write "Added support for Windows Server 2012 R2".
- Instead of "Fix for server connection issue", write "Fixed server connection issue".

## Code Review Process

- After submitting your pull request, our CI systems will run various tests
  and automatically update the status of the pull request.
- After all successful test pass, the module's maintainers will do a code review,
  commenting on any changes that might need to be made. If you are not designated
  as a module's maintainer, feel free to review others' Pull Requests as well,
  additional feedback is always welcome (leave your comments even if everything looks
  good - simple "Looks good to me" or "LGTM" will suffice, so that we know someone
  has already taken a look at it)!
- Once the code review is done, all merge conflicts are resolved, and the Appveyor
  build status is passing, a maintainer will merge your changes.

## CI Systems

We use multiple CI systems and evaluation systems to test the Pull Request and
branches to ensure quality of the project is maintained.

### Azure DevOps

We use [Azure DevOps](http://dev.azure.com/) as a continuous integration (CI) system.

![AzureDevOps-Badge-Green.png](Images/AzureDevOps-Badge-Green.png)

This badge is **clickable**, you can open corresponding build page with logs, artifacts
and tests results.
From there you can easily navigate to the whole build history.

AppVeyor builds and runs tests on every pull request and provides quick feedback
about it.

This is used to test the module on PowerShell on Windows and PowerShell Core on Linux.

### AppVeyor

We use [AppVeyor](http://www.appveyor.com/) as a continuous integration (CI) system.

![AppVeyor-Badge-Green.png](Images/AppVeyor-Badge-Green.png)

This badge is **clickable**, you can open corresponding build page with logs, artifacts
and tests results.
From there you can easily navigate to the whole build history.

AppVeyor builds and runs tests on every pull request and provides quick feedback
about it.

This is used to test the module on PowerShell on Windows.

### TravisCI

We use [TravisCI](http://travis-ci.org/) as a continuous integration (CI) system.

![TravisCI-Badge-Green.png](Images/TravisCI-Badge-Green.png)

This badge is **clickable**, you can open corresponding build page with logs, artifacts
and tests results.
From there you can easily navigate to the whole build history.

TravisCI builds and runs tests on every pull request and provides quick feedback
about it.

## Testing

- Any changed code should not cause Unit Tests to fail.
- Any new code should have Unit tests created for it.
- Unit Test files should exist under `/Tests/Unit`.
- Integration Test files should exist under `/Tests/Integration'.

## Branch structure

We are using a [git flow](http://nvie.com/posts/a-successful-git-branching-model/) model
for development.
We recommend that you create local working branches that target a specific scope of change.
Each branch should be limited to a single feature/bugfix both to streamline workflows
and reduce the possibility of merge conflicts.

![git flow picture](http://nvie.com/img/git-model@2x.png)
