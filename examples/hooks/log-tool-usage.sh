#!/usr/bin/env bash
# UserPromptSubmit hook — logs every user prompt to a file.
#
# Triggers: When the user submits a prompt (before Claude processes it).
# Behavior: Appends a timestamped entry to .claude/prompt-log.txt
# Exit code: Always exits 0 (allow the prompt to proceed).
#
# The hook receives a JSON object on stdin:
# { "prompt": "the user's prompt text", "session_id": "..." }

set -euo pipefail

# Read the JSON event from stdin
INPUT=$(cat)

# Extract the prompt text
PROMPT=$(echo "$INPUT" | jq -r '.prompt // "(empty)"')

# Create log directory if it doesn't exist
LOG_DIR=".claude"
LOG_FILE="$LOG_DIR/prompt-log.txt"
mkdir -p "$LOG_DIR"

# Append timestamped entry
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
echo "[$TIMESTAMP] $PROMPT" >> "$LOG_FILE"

# Always exit 0 to allow the prompt
exit 0
