# Dev Marketplace — Plugin Marketplace Example

A complete plugin marketplace with 3 plugins, each containing **commands**, **agents**, **skills**, and **hooks**.

## What's a Marketplace?

A marketplace is a catalog (`marketplace.json`) that lists plugins and where to find them. Users add your marketplace, browse plugins, and install what they need.

```
User runs:  /plugin marketplace add ./examples/dev-marketplace
            /plugin install lint-tools@dev-marketplace
Result:     /lint-tools:lint-fix command is now available
```

## Marketplace Structure

```
dev-marketplace/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace catalog (lists all plugins)
├── plugins/
│   ├── lint-tools/                   # Plugin 1: Linting
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json           # Plugin manifest
│   │   ├── commands/
│   │   │   └── lint-fix.md           # /lint-tools:lint-fix command
│   │   ├── agents/
│   │   │   └── lint-fixer.md         # Autonomous lint fixing agent
│   │   └── skills/
│   │       └── lint-fix/
│   │           └── SKILL.md          # Lint fix skill (Claude auto-invokes)
│   │
│   ├── security-tools/               # Plugin 2: Security
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   └── security-review.md    # /security-tools:security-review command
│   │   ├── agents/
│   │   │   └── security-scanner.md   # Proactive security scanning agent
│   │   └── skills/
│   │       └── security-review/
│   │           └── SKILL.md          # Security review skill
│   │
│   └── code-quality/                 # Plugin 3: Code Quality
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   └── review.md             # /code-quality:review command
│       ├── agents/
│       │   └── code-reviewer.md      # Code review subagent
│       └── hooks/
│           └── hooks.json            # Auto-format after Write/Edit
└── README.md
```

## Plugins

### lint-tools
| Component | Name | Description |
|-----------|------|-------------|
| Command | `/lint-tools:lint-fix` | Find and fix all lint errors (user-invoked) |
| Agent | `lint-fixer` | Autonomous lint fixing after code changes (Haiku, fast) |
| Skill | `lint-fix` | Lint instructions Claude auto-loads when relevant |

### security-tools
| Component | Name | Description |
|-----------|------|-------------|
| Command | `/security-tools:security-review` | OWASP Top 10 scan (user-invoked) |
| Agent | `security-scanner` | Proactive security audit (Sonnet, thorough) |
| Skill | `security-review` | Security knowledge Claude auto-loads when relevant |

### code-quality
| Component | Name | Description |
|-----------|------|-------------|
| Command | `/code-quality:review` | Review recent changes for quality (user-invoked) |
| Agent | `code-reviewer` | Code review subagent (Sonnet, read-only) |
| Hook | PostToolUse | Auto-format with Prettier after Write/Edit |

## Commands vs Skills vs Agents

| Feature | Commands (`commands/`) | Skills (`skills/`) | Agents (`agents/`) |
|---------|----------------------|-------------------|-------------------|
| **Invocation** | User types `/plugin:command` | Claude auto-loads when relevant | Claude delegates when task matches |
| **Context** | Runs in main conversation | Runs in main conversation | Runs in isolated context window |
| **Format** | Single `.md` file | `SKILL.md` in a directory | Single `.md` file |
| **Best for** | Actions you trigger manually | Knowledge Claude applies automatically | Heavy tasks that need isolation |

## marketplace.json Schema

```json
{
  "name": "dev-marketplace",           // Marketplace ID (used in install commands)
  "owner": { "name": "..." },          // Who maintains it
  "metadata": {
    "description": "...",              // What this marketplace offers
    "version": "1.0.0",
    "pluginRoot": "./plugins"          // Base path for relative sources
  },
  "plugins": [
    {
      "name": "lint-tools",            // Plugin ID (used in /plugin install)
      "source": "./plugins/lint-tools", // Where to find it (relative path)
      "description": "...",
      "version": "1.0.0",
      "category": "code-quality",      // For browsing/filtering
      "tags": ["linting", "eslint"],   // For search
      "license": "MIT"
    }
  ]
}
```

### Plugin Sources

Plugins can be sourced from:
- **Relative path**: `"./plugins/my-plugin"` — in same repo
- **GitHub**: `{ "source": "github", "repo": "owner/repo" }`
- **Git URL**: `{ "source": "url", "url": "https://gitlab.com/..." }`
- **npm**: `{ "source": "npm", "package": "@org/plugin" }`

## Usage

### Test locally

```bash
# Add this marketplace
/plugin marketplace add ./examples/dev-marketplace

# Browse available plugins
/plugin

# Install a plugin
/plugin install lint-tools@dev-marketplace
/plugin install security-tools@dev-marketplace
/plugin install code-quality@dev-marketplace

# Use the commands (namespaced by plugin name)
/lint-tools:lint-fix
/security-tools:security-review
/code-quality:review
```

### Host on GitHub

Push this directory to a GitHub repo, then users add it with:

```bash
/plugin marketplace add your-org/your-repo
```

### Team auto-install

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "dev-marketplace": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-code-tutorials"
      }
    }
  },
  "enabledPlugins": {
    "lint-tools@dev-marketplace": true,
    "security-tools@dev-marketplace": true,
    "code-quality@dev-marketplace": true
  }
}
```
