# Plugin Example — Tutorial Toolkit

A complete Claude Code plugin demonstrating skills, agents, and hooks bundled together.

## What Plugins Are

Plugins extend Claude Code with custom functionality that can be shared across projects and teams. A plugin bundles:

- **Skills** — reusable instructions (appear as `/plugin-name:skill-name`)
- **Agents** — specialized subagents with custom prompts and tool restrictions
- **Hooks** — shell commands that run at lifecycle events
- **MCP servers** — external tool integrations (via `.mcp.json`)
- **LSP servers** — language server configs (via `.lsp.json`)
- **Settings** — default configuration (via `settings.json`)

## Plugin Structure

```
tutorial-toolkit/
├── .claude-plugin/
│   └── plugin.json         # Plugin manifest (name, version, description)
├── skills/
│   └── greeting/
│       └── SKILL.md        # /tutorial-toolkit:greeting command
├── agents/
│   └── reviewer.md         # Quick code reviewer subagent
├── hooks/
│   └── hooks.json          # Auto-format + session reminder hooks
└── README.md
```

**Important**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, `agents/`, `hooks/`) must be at the plugin root level.

## What's Included

### Skill: `/tutorial-toolkit:greeting`
A personalized greeting command. Usage:
```
/tutorial-toolkit:greeting Alex
```

### Agent: `reviewer`
A fast code reviewer using Haiku that checks recent `git diff` for obvious issues.

### Hooks
- **PostToolUse**: Auto-formats files with Prettier after Write/Edit
- **Stop**: Reminds you to run tests when Claude finishes

## Installation

### Local testing (development)

```bash
claude --plugin-dir ./examples/plugin
```

### From a marketplace

If this plugin were published to a marketplace, you'd install it with:
```
/plugin install tutorial-toolkit
```

## Creating Your Own Plugin

### 1. Create the directory structure

```bash
mkdir -p my-plugin/.claude-plugin
mkdir -p my-plugin/skills/my-skill
mkdir -p my-plugin/agents
mkdir -p my-plugin/hooks
```

### 2. Create the manifest

Create `my-plugin/.claude-plugin/plugin.json`:
```json
{
  "name": "my-plugin",
  "description": "What your plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

### 3. Add components

- **Skills**: Add `SKILL.md` files in `skills/<skill-name>/`
- **Agents**: Add `.md` files in `agents/`
- **Hooks**: Create `hooks/hooks.json` with hook configuration
- **MCP**: Add `.mcp.json` at the plugin root
- **Settings**: Add `settings.json` for defaults

### 4. Test locally

```bash
claude --plugin-dir ./my-plugin
```

### 5. Distribute

- **Team sharing**: Push to a git repo, use as a marketplace
- **Official marketplace**: Submit at [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)

## Plugin vs Standalone

| Standalone (`.claude/`) | Plugin |
|-------------------------|--------|
| Skill: `/my-skill` | Skill: `/plugin-name:my-skill` |
| Project-specific | Shareable across projects |
| Files in `.claude/skills/` | Files in `plugin/skills/` |
| Hooks in `settings.json` | Hooks in `hooks/hooks.json` |
| Must manually copy | Install with `/plugin install` |
