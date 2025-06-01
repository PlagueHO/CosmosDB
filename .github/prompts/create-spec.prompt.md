---
mode: 'agent'
description: 'Create a new specification file for the solution, optimized for Generative AI consumption'
tools: [ "codebase", "read_file", "read_multiple_files", "write_file", "edit_file", "create_directory", "list_directory", "move_file", "search_files", "get_file_info", "list_allowed_directories"]
---
Your goal is to create a new specification file for `${input:SpecPurpose}` related to this CosmosDB PowerShel module.
The specification file must define the requirements, constraints, and interfaces for the solution components in a manner that is clear, unambiguous, and structured for effective use by Generative AIs. Follow established documentation standards and ensure the content is machine-readable and self-contained.
The specification should be saved in the [/spec/](/spec/) directory and named according to the following convention: `[a-z0-9-]+.md`, where the name should be descriptive of the specification's content and starting with the highlevel purpose, which is one of [schema, tool, data, infrastructure, process, architecture, or design].
The file should be formatted in well formed Markdown.

**Best Practices for AI-Ready Specifications:**
- Use precise, explicit, and unambiguous language.
- Clearly distinguish between requirements, constraints, and recommendations.
- Use structured formatting (headings, lists, tables) for easy parsing.
- Avoid idioms, metaphors, or context-dependent references.
- Define all acronyms and domain-specific terms.
- Include examples and edge cases where applicable.
- Ensure the document is self-contained and does not rely on external context.

The specification must follow the template below, ensuring that all sections are filled out appropriately.

# Specification: [Concise Title Describing the Specification's Focus]

**Version:** [Optional: e.g., 1.0, Date]
**Last Updated:** [Optional: YYYY-MM-DD]
**Owner:** [Optional: Team/Individual responsible for this spec]

## 1. Purpose & Scope

[Provide a clear, concise description of the specification's purpose and the scope of its application. State the intended audience and any assumptions.]

## 2. Definitions

[List and define all acronyms, abbreviations, and domain-specific terms used in this specification.]

## 3. Requirements, Constraints & Guidelines

[Explicitly list all requirements, constraints, rules, and guidelines. Use bullet points or tables for clarity.]

* Requirement 1: ...
* Constraint 1: ...
* Guideline 1: ...
* Pattern to follow: ...

## 4. Interfaces & Data Contracts

[Describe the interfaces, APIs, data contracts, or integration points. Use tables or code blocks for schemas and examples.]

## 5. Rationale & Context

[Explain the reasoning behind the requirements, constraints, and guidelines. Provide context for design decisions.]

## 6. Examples & Edge Cases

```
// Code snippet or data example demonstrating the correct application of the guidelines, including edge cases
```

## 7. Validation Criteria

[List the criteria or tests that must be satisfied for compliance with this specification.]

## 8. Related Specifications / Further Reading

[Link to related spec 1]
[Link to relevant external documentation]
