#!/bin/bash
# protect-claude-md.sh — Blocks any tool call that targets CLAUDE.md

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Check Edit/Write tools
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
if [[ "$FILE_PATH" == *"CLAUDE.md"* ]]; then
  echo "🚫 BLOCKED: Modification of CLAUDE.md is forbidden by policy." >&2
  exit 2
fi

# Check Bash commands
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if [[ "$COMMAND" == *"CLAUDE.md"* ]]; then
  echo "🚫 BLOCKED: Bash command targeting CLAUDE.md is forbidden by policy." >&2
  exit 2
fi

exit 0