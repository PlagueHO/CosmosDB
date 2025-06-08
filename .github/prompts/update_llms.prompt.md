---
mode: 'agent'
description: 'Update the llms.txt file in the root folder to reflect changes in documentation or specifications'
tools: [ "codebase", "read_file", "read_multiple_files", "write_file", "edit_file", "create_directory", "list_directory", "move_file", "search_files", "get_file_info", "list_allowed_directories"]
---
Your task is to update the [llms.txt](/llms.txt) file located in the root of the repository. This file provides high-level guidance to large language models (LLMs) on where to find relevant content for understanding the solution's purpose and specifications.

**Instructions:**
- Ensure the `llms.txt` file accurately references all folders and files that are important for LLM comprehension, including the `specs/` folder (for machine-readable specifications) and the `docs/` folder (for developer and user documentation).
- If new documentation or specification folders/files are added, update `llms.txt` accordingly.
- Use clear, concise language and structured formatting for easy parsing by LLMs.
- Do not include implementation details or code—focus on navigation and content discovery.

Example structure for `llms.txt`:

```
# Solution: [Concise Title Describing the Solution's Purpose]

**Version:** [Optional: e.g., 1.0, Date]
**Last Updated:** [Optional: YYYY-MM-DD]
**Owner:** [Optional: Team/Individual responsible for this solution]
**GitHub Repository:** https://github.com/PlagueHO/CosmosDB

## 1. Purpose & Scope

[Provide a clear, concise description of the purpose of this repository and scope of its solution. State the intended audience and any assumptions.]

## 2. Folder Structure

[Describe the structure of the repository, including the purpose of each folder and file. Use visual folder structure. Include subfolders where applicable.]

## 3. Important Files

[Explicitly list all important files, their purpose, and how they relate to the solution. Use bullet points or tables for clarity.]
