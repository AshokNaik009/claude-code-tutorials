---
name: review
description: Review recent code changes for quality, bugs, and best practices
allowed-tools: Read, Grep, Glob, Bash
disable-model-invocation: true
---

Review recent code changes for quality issues.

## Steps

1. Run `git diff` to see recent changes
2. For each changed file, review for:
   - Potential bugs or edge cases
   - Code clarity and naming
   - Duplicated logic
   - Missing error handling
   - Performance concerns
3. Provide feedback organized by priority:
   - **Critical** — must fix before merging
   - **Warning** — should fix
   - **Suggestion** — nice to have
4. Include specific code examples showing how to fix each issue
