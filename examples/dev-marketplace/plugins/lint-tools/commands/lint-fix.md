---
name: lint-fix
description: Find and fix all lint errors in the project
allowed-tools: Bash, Read, Edit, Grep, Glob
disable-model-invocation: true
---

Find and fix all lint errors in the current project.

## Steps

1. **Detect language** — check for `package.json` (JS/TS) or `pyproject.toml`/`*.py` (Python)
2. **Run linter** — `npx eslint . --format json` or `ruff check . --output-format json`
3. **Auto-fix** — `npx eslint . --fix` or `ruff check . --fix`
4. **Fix remaining** — read each file with errors, apply manual fixes via Edit
5. **Verify** — re-run linter to confirm zero errors
6. **Report** — summarize what was found and fixed
