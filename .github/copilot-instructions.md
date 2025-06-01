This is a PowerShell module for managing and interacting with Azure Cosmos DB accounts, database, collections and related entities.
It is designed to be used on Windows, MacOS and Linux platforms, using PowerShell 7 and above. It does currently support PowerShell 5.x, but this will be deprecated.
It is primarily written in PowerShell, but also includes some C# classes to implement custom types.

The key principles you should adopt when suggesting PowerShell or C# code:
- Use PowerShell best practices and optimize for performance and maintainability, preferring approaches that are most efficient on PowerShell 7 and above.
- Use Pester 4.x for unit tests and integration tests. Pester 5.x is not supported but is planned.
- Prioritize security, testability, and maintainability in all code suggestions.
- Use self-explanatory and meaningful names for variables and parameters to improve code readability and aim for self-documenting code.
- Always provide descriptions of functions and parameters, using the `Comment-Based Help` style.
- Always include parameter names, even when positional parameters are available, to improve code readability and maintainability.
- Avoid long functions break large functions down into smaller, self-contained private utility functions where appropriate.
- Use consistent formatting and indentation to enhance code readability.
- Parameters always start with uppercase letters, local variables are camelCase and function names are PascalCase with valid PowerShell verb-noun construct.
