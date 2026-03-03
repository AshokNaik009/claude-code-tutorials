#!/usr/bin/env node
// PostToolUse hook — auto-formats code after Write or Edit tool calls.
//
// Triggers: After the Write or Edit tool modifies a file.
// Behavior: Runs Prettier (JS/TS/JSON/CSS) or Black (Python) on the changed file.
// Exit code: Always exits 0 (allow the tool call to proceed).
//
// The hook receives a JSON object on stdin with the tool call details.
// For Write/Edit, the JSON includes: { "tool_name": "Write", "tool_input": { "file_path": "..." } }

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Read JSON from stdin
let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  input += chunk;
});

process.stdin.on("end", () => {
  try {
    const event = JSON.parse(input);
    const toolName = event.tool_name || "";
    const filePath = event.tool_input?.file_path || "";

    // Only act on Write or Edit tools
    if (toolName !== "Write" && toolName !== "Edit") {
      process.exit(0);
    }

    // Skip if no file path or file doesn't exist
    if (!filePath || !fs.existsSync(filePath)) {
      process.exit(0);
    }

    const ext = path.extname(filePath).slice(1);

    // Prettier-supported extensions
    const prettierExts = [
      "js",
      "jsx",
      "ts",
      "tsx",
      "json",
      "css",
      "scss",
      "md",
      "html",
      "yaml",
      "yml",
    ];

    if (prettierExts.includes(ext)) {
      try {
        execSync(`npx --yes prettier --write "${filePath}"`, {
          stdio: "ignore",
        });
      } catch {
        // Prettier not available or failed — continue silently
      }
    } else if (ext === "py") {
      try {
        execSync(`black --quiet "${filePath}"`, { stdio: "ignore" });
      } catch {
        // Black not available or failed — continue silently
      }
    }
  } catch {
    // JSON parse error or unexpected issue — exit cleanly
  }

  // Always exit 0 to allow the tool call
  process.exit(0);
});
