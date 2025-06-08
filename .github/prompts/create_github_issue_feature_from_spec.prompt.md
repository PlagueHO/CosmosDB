---
mode: 'agent'
description: 'Create a GitHub Issue for a feature request using the GitHub Issue template feature_request.yml from a specification file.'
tools: [ "create_issue", "get_issue", "list_issues", "search_issues", "update_issue", "websearch", "codebase", "gitHubRepo", "directory_tree", "read_file", "read_multiple_files", "write_file", "edit_file", "create_directory", "list_directory", "move_file", "search_files", "get_file_info", "list_allowed_directories"]
---
Create a GitHub Issue in this GitHub repo using the `create_issue` tool for a feature request to implement the specification in the spec file [${input:SpecFile}](../spec/${input:SpecFile}) using the GitHub Issue template [feature_request.yml](../ISSUE_TEMPLATE/feature_request.yml).
If the issue already exists, you should update it with the latest information from the spec file.
The specification file contains the details of the feature request, including the problem statement, proposed solution, and any additional context or requirements and should be clearly identified in the GitHub issue title.
The issue should be clear, concise, and structured to facilitate understanding and implementation by the development team.
It should only apply changes that are neccessary to implement the specification file and not any other changes that are not required because they are already implemented.
