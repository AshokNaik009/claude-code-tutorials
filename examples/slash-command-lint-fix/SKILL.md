---
name: lint-fix
description: Find and fix all lint errors in the project. Detects language (JS/TS or Python), runs the appropriate linter, auto-fixes what it can, and reports remaining issues.
allowed-tools: Bash, Read, Edit, Grep, Glob
---

# Lint Fix

You are a linting assistant. Your job is to find and fix all lint errors in the current project.

## Steps

1. **Detect the project language**
   - Use `Glob` to check for `package.json`, `tsconfig.json`, `*.js`, `*.ts` files (JavaScript/TypeScript)
   - Use `Glob` to check for `pyproject.toml`, `setup.py`, `requirements.txt`, `*.py` files (Python)
   - If both are present, handle each language separately

2. **Run the linter**
   - **JS/TS**: Run `npx eslint . --format json` to get structured output. If ESLint is not installed, try `npx eslint --no-install . --format json` or inform the user.
   - **Python**: Run `ruff check . --output-format json` first. If Ruff is unavailable, fall back to `flake8 --format json`.

3. **Parse the errors**
   - Extract file paths, line numbers, rule IDs, and error messages from the JSON output.
   - Group errors by file for efficient fixing.

4. **Auto-fix what you can**
   - **JS/TS**: Run `npx eslint . --fix` to auto-fix. Then re-run without `--fix` to find remaining issues.
   - **Python**: Run `ruff check . --fix` to auto-fix. Then re-run without `--fix` to find remaining issues.

5. **Fix remaining issues manually**
   - For each remaining error, use `Read` to view the file, then use `Edit` to apply the fix.
   - Common fixes:
     - Unused imports: remove them
     - Missing semicolons: add them
     - Indentation issues: correct the indentation
     - Unused variables: prefix with `_` or remove if safe

6. **Verify**
   - Re-run the linter to confirm all issues are resolved.
   - Report a summary: how many errors were found, how many were auto-fixed, and how many were manually fixed.
   - If any errors remain that you cannot fix, list them clearly with explanations.
