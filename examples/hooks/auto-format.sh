#!/usr/bin/env bash
# PostToolUse hook — auto-formats code after Write or Edit tool calls.
#
# Triggers: After the Write or Edit tool modifies a file.
# Behavior: Runs Prettier (JS/TS/JSON/CSS) or Black (Python) on the changed file.
# Exit code: Always exits 0 (allow the tool call to proceed).
#
# The hook receives a JSON object on stdin with the tool call details.
# For Write/Edit, the JSON includes: { "tool_name": "Write", "tool_input": { "file_path": "..." } }

set -euo pipefail

# Read the JSON event from stdin
INPUT=$(cat)

# Extract the tool name and file path
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only act on Write or Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Get the file extension
EXT="${FILE_PATH##*.}"

case "$EXT" in
  js|jsx|ts|tsx|json|css|scss|md|html|yaml|yml)
    # Format with Prettier if available
    if command -v npx &>/dev/null; then
      npx --yes prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    # Format with Black if available
    if command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

# Always exit 0 to allow the tool call
exit 0
