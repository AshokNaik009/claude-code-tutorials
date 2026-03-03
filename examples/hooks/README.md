# Hooks — Auto-Format & Prompt Logging

Two example hooks for Claude Code that run shell scripts in response to lifecycle events.

## Hook 1: Auto-Format (`auto-format.sh`)

**Event**: `PostToolUse` — runs after Claude uses the Write or Edit tool.

**What it does**: Automatically formats the modified file using:
- **Prettier** for JS, TS, JSON, CSS, HTML, Markdown, YAML
- **Black** for Python

### Prerequisites

```bash
# For JS/TS/JSON/CSS formatting
npm install --save-dev prettier

# For Python formatting
pip install black
```

## Hook 2: Prompt Logger (`log-tool-usage.sh`)

**Event**: `UserPromptSubmit` — runs when you submit a prompt to Claude.

**What it does**: Appends every prompt with a UTC timestamp to `.claude/prompt-log.txt`.

Example log output:
```
[2025-01-15T10:30:00Z] fix the bug in auth.py
[2025-01-15T10:32:15Z] add tests for the login endpoint
[2025-01-15T10:45:00Z] /lint-fix
```

## Installation

1. Copy the hook scripts into your project:

```bash
mkdir -p .claude/hooks
cp auto-format.sh .claude/hooks/
cp log-tool-usage.sh .claude/hooks/
chmod +x .claude/hooks/auto-format.sh
chmod +x .claude/hooks/log-tool-usage.sh
```

2. Add the hook configuration to `.claude/settings.json`:

```bash
cp settings.json .claude/settings.json
```

Or merge the `"hooks"` key into your existing `.claude/settings.json`.

## Configuration Format

Hooks are configured in `.claude/settings.json` under the `hooks` key:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern to match (regex for tool names, empty for all)",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/your-script.sh"
          }
        ]
      }
    ]
  }
}
```

### Lifecycle Events

| Event | When It Fires | Stdin JSON |
|-------|---------------|------------|
| `UserPromptSubmit` | User submits a prompt | `{ "prompt": "..." }` |
| `PostToolUse` | After a tool call completes | `{ "tool_name": "...", "tool_input": {...} }` |
| `PreToolUse` | Before a tool call executes | `{ "tool_name": "...", "tool_input": {...} }` |
| `Notification` | Claude sends a notification | `{ "message": "..." }` |

### Exit Codes

| Exit Code | Effect |
|-----------|--------|
| `0` | Allow — the operation proceeds normally |
| `2` | Block — the operation is prevented (with stderr shown as the reason) |
| Any other | Error — treated as a hook failure |

## How Hooks Work

1. Claude Code fires a **lifecycle event** (e.g., after editing a file)
2. The event is matched against the `matcher` regex (for tool-based events, this matches the tool name)
3. If matched, the configured command runs with event data piped to stdin as JSON
4. The script's exit code determines whether the operation proceeds or is blocked
