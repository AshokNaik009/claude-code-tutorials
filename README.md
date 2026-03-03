# Claude Code Tutorials

Hands-on examples for five key Claude Code extensibility features: **Skills & Slash Commands**, **Subagents**, **Hooks**, **Plugins**, and a ready-to-use **`.claude/` directory**.

Each feature has working examples you can copy into your project and start using immediately.

| Example | Feature | Directory |
|---------|---------|-----------|
| `/lint-fix` command | Skills (Slash Command) | [`examples/slash-command-lint-fix/`](examples/slash-command-lint-fix/) |
| Security review | Skills | [`examples/custom-skill/`](examples/custom-skill/) |
| Code reviewer agent | Subagents | [`examples/agents/`](examples/agents/) |
| Auto-format + prompt logger | Hooks | [`examples/hooks/`](examples/hooks/) |
| Tutorial toolkit | Plugins | [`examples/plugin/`](examples/plugin/) |
| Ready-to-use install | All features | [`.claude/`](.claude/) |

## `.claude/` Directory Structure

This repo includes a ready-to-use `.claude/` directory with all features installed:

```
.claude/
├── skills/                        # Skills (= custom slash commands)
│   ├── lint-fix/
│   │   └── SKILL.md              # /lint-fix — find and fix lint errors
│   └── security-review/
│       └── SKILL.md              # /security-review — scan for vulnerabilities
├── agents/                        # Custom subagents
│   └── code-reviewer.md          # Code review subagent (Sonnet, read-only)
├── hooks/                         # Hook scripts
│   ├── auto-format.js            # PostToolUse — format after Write/Edit
│   └── log-tool-usage.sh         # UserPromptSubmit — log every prompt
└── settings.json                  # Hooks configuration
```

---

## Skills & Slash Commands

Skills extend what Claude can do. A `SKILL.md` file with instructions gets added to Claude's toolkit. Claude uses skills when relevant, or you invoke one directly with `/skill-name`.

**Custom slash commands are skills.** A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way.

### Built-in Commands

| Command | What It Does |
|---------|-------------|
| `/help` | Show help and available commands |
| `/init` | Initialize a CLAUDE.md file for your project |
| `/clear` | Clear conversation history |
| `/compact` | Compact conversation to save context |
| `/config` | Open Claude Code settings |
| `/cost` | Show token usage and cost for the session |
| `/doctor` | Check Claude Code installation health |
| `/agents` | Manage custom subagents |
| `/hooks` | Manage lifecycle hooks |
| `/memory` | Edit your CLAUDE.md memory files |
| `/review` | Review a pull request |
| `/simplify` | Review recent changes for quality and efficiency |
| `/batch` | Orchestrate large-scale changes across a codebase in parallel |

### Bundled Skills

These ship with Claude Code and are available in every session:

| Skill | What It Does |
|-------|-------------|
| `/simplify` | Reviews recently changed files for reuse, quality, and efficiency — spawns 3 review agents in parallel |
| `/batch <instruction>` | Decomposes large changes into 5-30 independent units, each in an isolated git worktree with its own agent |
| `/debug [description]` | Troubleshoots your current session by reading the debug log |

### Skill File Format

Each skill is a directory with `SKILL.md` as the entrypoint:

```
my-skill/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in (optional)
├── examples/          # Example outputs (optional)
└── scripts/           # Scripts Claude can execute (optional)
```

The `SKILL.md` has YAML frontmatter + markdown body:

```yaml
---
name: lint-fix                    # Slash command name (optional)
description: What it does         # Shown in autocomplete + used by Claude
allowed-tools: Bash, Read, Edit   # Tool restrictions (optional)
disable-model-invocation: true    # Only user can invoke (optional)
user-invocable: true              # Show in /menu (default: true)
context: fork                     # Run in isolated subagent (optional)
agent: Explore                    # Subagent type for context:fork (optional)
model: sonnet                     # Model override (optional)
---

Instructions for Claude go here...
Use $ARGUMENTS for user-provided input.
Use $ARGUMENTS[0], $ARGUMENTS[1] for positional args.
Use !`shell command` for dynamic context injection.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Slash command name (lowercase, hyphens, max 64 chars) |
| `description` | Recommended | What the skill does; Claude uses this to decide when to load it |
| `argument-hint` | No | Autocomplete hint, e.g., `[issue-number]` |
| `disable-model-invocation` | No | `true` = only user can invoke (not Claude) |
| `user-invocable` | No | `false` = hide from `/` menu (background knowledge only) |
| `allowed-tools` | No | Restrict tools when skill is active |
| `model` | No | Model override |
| `context` | No | `fork` = run in isolated subagent context |
| `agent` | No | Subagent type when `context: fork` (default: `general-purpose`) |
| `hooks` | No | Hooks scoped to this skill's lifecycle |

### Where Skills Live

| Location | Scope | Priority |
|----------|-------|----------|
| Enterprise managed settings | All users in org | Highest |
| `~/.claude/skills/<name>/SKILL.md` | All your projects | High |
| `.claude/skills/<name>/SKILL.md` | This project only | Normal |
| Plugin `skills/` directory | Where plugin enabled | Lowest |

### Invocation Control

| Frontmatter | You invoke | Claude invokes | Use case |
|-------------|-----------|---------------|----------|
| (default) | Yes | Yes | General-purpose skills |
| `disable-model-invocation: true` | Yes | No | Side-effect workflows (`/deploy`, `/commit`) |
| `user-invocable: false` | No | Yes | Background knowledge skills |

See: [`examples/slash-command-lint-fix/`](examples/slash-command-lint-fix/) and [`examples/custom-skill/`](examples/custom-skill/)

---

## Subagents

Subagents are specialized AI assistants that run in their own isolated context window. Each gets a custom system prompt, specific tool access, and independent permissions. They work independently and return a summary — keeping the parent's context clean.

### How Subagents Work

```
┌──────────────────────────────────────────────────────┐
│                    PARENT AGENT                       │
│                                                       │
│  Context: [ user request, files read, plans... ]      │
│                                                       │
│  "Research the auth system and check test coverage."  │
│                                                       │
│         ┌──────────┐       ┌──────────┐               │
│         │  spawn    │       │  spawn    │              │
│         ▼          │       ▼          │              │
│  ┌─────────────┐   │ ┌─────────────┐  │              │
│  │  SUBAGENT 1 │   │ │  SUBAGENT 2 │  │              │
│  │  (Explore)  │   │ │  (Bash)     │  │              │
│  │             │   │ │             │  │              │
│  │ Reads 20    │   │ │ Runs test   │  │              │
│  │ files,      │   │ │ commands,   │  │              │
│  │ searches    │   │ │ parses      │  │              │
│  │ codebase    │   │ │ output      │  │              │
│  └──────┬──────┘   │ └──────┬──────┘  │              │
│         │          │        │         │              │
│         ▼          │        ▼         │              │
│    ┌─────────┐     │   ┌─────────┐    │              │
│    │ Summary │     │   │ Summary │    │              │
│    └────┬────┘     │   └────┬────┘    │              │
│         └──────────┴────────┘         │              │
│                    │                                  │
│                    ▼                                  │
│  Context: [ ...previous, auth summary,                │
│             coverage summary ]                        │
│                                                       │
│  Only summaries enter the parent context.             │
│  The 20 files and test output stay in the             │
│  subagents' windows — never seen by parent.           │
└──────────────────────────────────────────────────────┘
```

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **Explore** | Haiku (fast) | Read-only | Codebase search and exploration |
| **Plan** | Inherit | Read-only | Research for plan mode |
| **general-purpose** | Inherit | All | Complex multi-step tasks |
| **Bash** | Inherit | Bash | Terminal commands in separate context |

### Custom Subagent Format

Agent files are Markdown with YAML frontmatter stored in `.claude/agents/`:

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after code changes.
tools: Read, Glob, Grep, Bash
model: sonnet
---

You are a senior code reviewer. When invoked:
1. Run git diff to see recent changes
2. Review modified files
3. Report findings by priority
```

### Subagent Frontmatter Fields

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

### Agent Scope (Priority Order)

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` | Where plugin enabled | 4 (lowest) |

### Agent Teams

For large tasks, Claude can spawn a **team** of agents that work in parallel with a shared task list and direct messaging:

```
┌─────────────────────────────────────────────────────────────┐
│                        TEAM LEAD                            │
│                                                             │
│  Creates tasks, assigns work, reviews results               │
│                                                             │
│         ┌──────────┬──────────┬──────────┐                  │
│         ▼          ▼          ▼          │                  │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐              │
│  │ Teammate A │ │ Teammate B │ │ Teammate C │              │
│  │ (frontend) │ │ (backend)  │ │ (tests)    │              │
│  │            │ │            │ │            │              │
│  │ Edit React │ │ Add API    │ │ Write test │              │
│  │ components │ │ endpoints  │ │ suites     │              │
│  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘              │
│        │              │              │                      │
│        └──────────────┼──────────────┘                      │
│                       ▼                                     │
│              ┌─────────────────┐                            │
│              │ Shared Task List │                           │
│              │                 │                            │
│              │ [x] Task 1     │                            │
│              │ [x] Task 2     │                            │
│              │ [ ] Task 3     │                            │
│              └─────────────────┘                            │
│                                                             │
│  Teammates communicate via direct messages.                 │
│  The lead assigns tasks and coordinates.                    │
└─────────────────────────────────────────────────────────────┘
```

Key properties:
- **Context isolation** — subagents don't pollute the parent's context window
- **Parallel execution** — multiple subagents can run simultaneously
- **Focused tools** — each type has only the tools it needs
- **Resumable** — subagents can be resumed with full prior context
- **Persistent memory** — agents with `memory` build knowledge over time

See: [`examples/agents/`](examples/agents/)

---

## Hooks

Hooks are shell commands that execute at specific points in Claude Code's lifecycle. They provide deterministic control — ensuring certain actions always happen rather than relying on the LLM.

### Lifecycle Events

| Event | When It Fires | Matcher Matches |
|-------|---------------|-----------------|
| `SessionStart` | Session begins or resumes | `startup`, `resume`, `clear`, `compact` |
| `UserPromptSubmit` | User submits a prompt | (no matcher) |
| `PreToolUse` | Before a tool call | Tool name |
| `PostToolUse` | After a tool call succeeds | Tool name |
| `PostToolUseFailure` | After a tool call fails | Tool name |
| `PermissionRequest` | Permission dialog appears | Tool name |
| `Notification` | Claude sends notification | Notification type |
| `SubagentStart` | Subagent spawned | Agent type name |
| `SubagentStop` | Subagent completes | Agent type name |
| `Stop` | Claude finishes responding | (no matcher) |
| `ConfigChange` | Config file changes | Config source |
| `PreCompact` | Before context compaction | `manual`, `auto` |
| `SessionEnd` | Session terminates | Exit reason |

### Hook Types

| Type | Description |
|------|-------------|
| `command` | Run a shell command (most common) |
| `http` | POST event data to a URL |
| `prompt` | Single-turn LLM evaluation (yes/no decision) |
| `agent` | Multi-turn verification with tool access |

### Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

- **`matcher`** — regex matched against tool name (empty string = match all)
- **`command`** — shell command to run; receives event data as JSON on stdin
- **`type`** — `command`, `http`, `prompt`, or `agent`

### Exit Codes

| Exit Code | Effect |
|-----------|--------|
| `0` | **Allow** — operation proceeds. Stdout is added to context (for `UserPromptSubmit`/`SessionStart`) |
| `2` | **Block** — operation is prevented. Stderr is fed back to Claude as reason |
| Other | **Error** — treated as a hook failure, action proceeds |

### Hook Input (JSON on stdin)

```json
{
  "session_id": "abc123",
  "cwd": "/path/to/project",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

### Where Hooks Live

| Location | Scope |
|----------|-------|
| `~/.claude/settings.json` | All your projects |
| `.claude/settings.json` | Single project (shareable) |
| `.claude/settings.local.json` | Single project (gitignored) |
| Plugin `hooks/hooks.json` | Where plugin enabled |
| Skill/agent frontmatter | While skill/agent active |

See: [`examples/hooks/`](examples/hooks/)

---

## Plugins

Plugins bundle skills, agents, hooks, and MCP servers into a shareable package. Skills get namespaced (`/plugin-name:skill-name`) to prevent conflicts.

### Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Manifest (name, version, description)
├── skills/                   # Custom skills
│   └── greeting/
│       └── SKILL.md
├── agents/                   # Custom subagents
│   └── reviewer.md
├── hooks/                    # Lifecycle hooks
│   └── hooks.json
├── commands/                 # Legacy commands (same as skills)
├── .mcp.json                # MCP server configs (optional)
├── .lsp.json                # LSP server configs (optional)
├── settings.json            # Default settings (optional)
└── README.md
```

**Important**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories go at the plugin root.

### Plugin Manifest

```json
{
  "name": "my-plugin",
  "description": "What your plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" },
  "homepage": "https://github.com/...",
  "license": "MIT"
}
```

The `name` field becomes the skill namespace: `skills/hello/` creates `/my-plugin:hello`.

### Using Plugins

```bash
# Test locally during development
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two

# Install from a marketplace
/plugin install my-plugin
```

### Plugin vs Standalone

| Standalone (`.claude/`) | Plugin |
|-------------------------|--------|
| Skill: `/my-skill` | Skill: `/plugin-name:my-skill` |
| Project-specific | Shareable across projects |
| Files in `.claude/skills/` | Files in `plugin/skills/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Must manually copy | Install with `/plugin install` |

### Publishing

- Submit to the official marketplace at [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Create a team marketplace by hosting a git repo with plugin directories

See: [`examples/plugin/`](examples/plugin/)

---

## Getting Started

### Option 1: Use the pre-built `.claude/` directory

This repo's `.claude/` directory is ready to use. Just clone and start Claude Code:

```bash
git clone <this-repo>
cd claude-code-tutorials
claude
```

Then try:
- `/lint-fix` — run the linter and fix errors
- `/security-review` — scan for vulnerabilities
- Ask Claude to review code — it delegates to the `code-reviewer` agent
- Edit a file — auto-format runs automatically
- Check `.claude/prompt-log.txt` to see logged prompts

### Option 2: Copy individual examples into your project

```bash
# Skills
mkdir -p .claude/skills/lint-fix .claude/skills/security-review
cp examples/slash-command-lint-fix/SKILL.md .claude/skills/lint-fix/
cp examples/custom-skill/SKILL.md .claude/skills/security-review/

# Agents
mkdir -p .claude/agents
cp examples/agents/code-reviewer.md .claude/agents/

# Hooks
mkdir -p .claude/hooks
cp examples/hooks/auto-format.js .claude/hooks/
cp examples/hooks/log-tool-usage.sh .claude/hooks/
chmod +x .claude/hooks/auto-format.js .claude/hooks/log-tool-usage.sh
cp examples/hooks/settings.json .claude/settings.json

# Test the plugin
claude --plugin-dir ./examples/plugin
```

### Option 3: Use the `/hooks` and `/agents` interactive menus

Claude Code has built-in menus for creating hooks and agents interactively:

```
/hooks    # Create and manage hooks
/agents   # Create and manage subagents
```
