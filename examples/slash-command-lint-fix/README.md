# /lint-fix — Custom Slash Command

A custom slash command that finds and fixes all lint errors in your project.

## What It Does

- Detects your project language (JavaScript/TypeScript or Python)
- Runs the appropriate linter (ESLint or Ruff/Flake8)
- Auto-fixes what it can
- Manually fixes remaining issues
- Re-runs the linter to verify everything is clean

## Installation

Copy `SKILL.md` into your project's `.claude/skills/` directory:

```bash
mkdir -p .claude/skills
cp SKILL.md .claude/skills/lint-fix.md
```

Or install it as a user-level skill (available in all projects):

```bash
mkdir -p ~/.claude/skills
cp SKILL.md ~/.claude/skills/lint-fix.md
```

## Usage

In Claude Code, type:

```
/lint-fix
```

Claude will detect your project type and run the appropriate linting workflow.

## Prerequisites

For JavaScript/TypeScript projects:
- ESLint installed (`npm install --save-dev eslint`)

For Python projects:
- Ruff (`pip install ruff`) or Flake8 (`pip install flake8`)

## How It Works

In Claude Code, custom slash commands **are skills**. A skill is a Markdown file with YAML frontmatter that tells Claude:

- **name**: The slash command name (what you type after `/`)
- **description**: What the command does (shown in autocomplete)
- **allowed-tools**: Which tools the skill can use

The body of the Markdown file contains the instructions Claude follows when the command is invoked.
