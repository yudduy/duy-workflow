#!/bin/bash

# Format-on-save hook for Write/Edit operations
# Detects project formatter and runs it silently on the edited file
# Always exits 0 (non-blocking) - formatting is best-effort

set -uo pipefail

# Read hook input from stdin
HOOK_INPUT=$(cat 2>/dev/null || echo '{}')

# Extract file_path from tool input
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit if no file path
[[ -z "$FILE_PATH" ]] && exit 0

# Exit if file doesn't exist
[[ ! -f "$FILE_PATH" ]] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

# Function to find project root (look for common markers)
find_project_root() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/package.json" ]] || \
       [[ -f "$dir/pyproject.toml" ]] || \
       [[ -f "$dir/Cargo.toml" ]] || \
       [[ -f "$dir/go.mod" ]] || \
       [[ -d "$dir/.git" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# Find project root
PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")" 2>/dev/null)

# Format based on file type
case "$EXT" in
  js|jsx|ts|tsx|json|css|scss|html|md|yaml|yml)
    # JavaScript/TypeScript/Web files - try prettier
    if [[ -n "$PROJECT_ROOT" ]] && [[ -f "$PROJECT_ROOT/node_modules/.bin/prettier" ]]; then
      "$PROJECT_ROOT/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
  py)
    # Python - try black, then ruff
    if command -v black &>/dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null
    elif command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
    fi
    ;;
  go)
    # Go - use gofmt
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rs)
    # Rust - use rustfmt
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
  rb)
    # Ruby - try rubocop
    if command -v rubocop &>/dev/null; then
      rubocop -a --fail-level fatal "$FILE_PATH" 2>/dev/null
    fi
    ;;
  sh|bash)
    # Shell - try shfmt
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

# Always exit 0 - formatting is non-blocking
exit 0
