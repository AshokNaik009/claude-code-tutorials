# Custom Subagent — Code Reviewer

A custom subagent that reviews code for quality, security, and maintainability.

## What Subagents Are

Subagents are specialized AI assistants that run in their own isolated context window. Each subagent has:
- A custom **system prompt** (the markdown body)
- Specific **tool access** (configured in frontmatter)
- Its own **model** selection
- Independent **permissions**

When Claude encounters a task matching a subagent's description, it delegates to that subagent. The subagent works independently and returns a summary — keeping the parent's context clean.

## What This Agent Does

- Runs `git diff` to find recent changes
- Reviews modified files for quality, security, and maintainability
- Reports issues by priority: Critical, Warnings, Suggestions
- Uses read-only tools (cannot modify your code)

## Installation

Copy `code-reviewer.md` into your project's `.claude/agents/` directory:

```bash
mkdir -p .claude/agents
cp code-reviewer.md .claude/agents/
```

Or install as a user-level agent (available in all projects):

```bash
mkdir -p ~/.claude/agents
cp code-reviewer.md ~/.claude/agents/
```

## Usage

Claude delegates to the agent automatically when you ask for a code review:

```
Review my recent changes for quality issues
```

Or reference it explicitly:

```
Use the code-reviewer agent to look at my recent changes
```

You can also manage agents interactively:

```
/agents
```

## Agent File Format

Agent files are Markdown with YAML frontmatter:

```yaml
---
name: code-reviewer              # Unique identifier (required)
description: What it does        # When Claude should delegate (required)
tools: Read, Glob, Grep, Bash   # Tool restrictions (optional)
model: sonnet                    # Model: sonnet, opus, haiku, inherit (optional)
permissionMode: default          # Permission handling (optional)
maxTurns: 20                     # Max agentic turns (optional)
memory: user                     # Persistent memory scope (optional)
---

System prompt instructions go here...
```

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When Claude should delegate to this agent |
| `tools` | No | Allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximum agentic turns |
| `skills` | No | Skills to preload into the agent's context |
| `mcpServers` | No | MCP servers available to this agent |
| `hooks` | No | Lifecycle hooks scoped to this agent |
| `memory` | No | Persistent memory: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task |
| `isolation` | No | `worktree` for isolated git worktree |

## Built-in Agents

Claude Code includes these built-in subagents:

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku | Read-only | Fast codebase search and exploration |
| Plan | Inherit | Read-only | Codebase research for planning |
| general-purpose | Inherit | All | Complex multi-step tasks |
| Bash | Inherit | Bash | Terminal commands in separate context |

## Agent Scope (Priority Order)

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` | Where plugin enabled | 4 (lowest) |
