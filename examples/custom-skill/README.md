# Security Review — Custom Skill

A Claude Code skill that analyzes your codebase for security vulnerabilities.

## What It Does

- Scans for hardcoded secrets (API keys, passwords, tokens)
- Checks for injection vulnerabilities (SQL, command, XSS)
- Reviews authentication and authorization patterns
- Audits dependencies for known vulnerabilities
- Reports findings with severity levels and remediation steps

## Installation

Copy `SKILL.md` into your project's `.claude/skills/` directory:

```bash
mkdir -p .claude/skills
cp SKILL.md .claude/skills/security-review.md
```

Or install it as a user-level skill (available in all projects):

```bash
mkdir -p ~/.claude/skills
cp SKILL.md ~/.claude/skills/security-review.md
```

## Usage

In Claude Code, type:

```
/security-review
```

Or Claude may invoke it automatically when you ask it to review code for security issues.

## Example Output

```
### [HIGH] Hardcoded Database Password

- **File**: src/db/connection.py:15
- **Category**: A07:2021 - Identification and Authentication Failures
- **Description**: Database password is hardcoded in source code
- **Impact**: Credentials exposed if source code is leaked
- **Fix**: Move to environment variable and use os.environ["DB_PASSWORD"]
```

## Skills vs. Slash Commands

In Claude Code, skills and slash commands are the same thing. A skill is a Markdown file with:

- **YAML frontmatter** — metadata like `name`, `description`, and `allowed-tools`
- **Markdown body** — the instructions Claude follows

When a skill has a `name` field, it becomes available as `/name` in the slash command menu.
