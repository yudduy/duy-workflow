#!/bin/bash

# Cancel Ralph loop script
# Usage: cancel-ralph.sh [--list | --all]

set -uo pipefail

CLAUDE_SESSION_PID=$PPID
STATE_FILE=".claude/ralph-loop.${CLAUDE_SESSION_PID}.local.md"

# Parse arguments
LIST_ONLY=false
CANCEL_ALL=false
for arg in "$@"; do
  case $arg in
    --list) LIST_ONLY=true ;;
    --all) CANCEL_ALL=true ;;
  esac
done

# List active loops
echo "Active Ralph loops:"
FOUND_ANY=false
shopt -s nullglob
for f in .claude/ralph-loop.*.local.md; do
  [[ ! -f "$f" ]] && continue
  FOUND_ANY=true
  LOOP_PID=$(echo "$f" | sed 's/.*ralph-loop\.\([0-9]*\)\.local\.md/\1/')
  ITERATION=$(grep '^iteration:' "$f" 2>/dev/null | sed 's/iteration: *//' || echo "?")
  MAX_ITER=$(grep '^max_iterations:' "$f" 2>/dev/null | sed 's/max_iterations: *//' || echo "?")
  MARKER=$([[ "$LOOP_PID" == "$PPID" ]] && echo " <-- THIS SESSION" || echo "")
  echo "  - PID $LOOP_PID: iteration $ITERATION/$MAX_ITER$MARKER"
done

[[ "$FOUND_ANY" == "false" ]] && { echo "  (none)"; exit 0; }
echo ""

# Handle --list
[[ "$LIST_ONLY" == "true" ]] && exit 0

# Handle --all
if [[ "$CANCEL_ALL" == "true" ]]; then
  rm -f .claude/ralph-loop.*.local.md
  echo "Cancelled all Ralph loops."
  exit 0
fi

# Cancel this session's loop
if [[ -f "$STATE_FILE" ]]; then
  ITERATION=$(grep '^iteration:' "$STATE_FILE" | sed 's/iteration: *//')
  rm "$STATE_FILE"
  echo "Cancelled Ralph loop for this session (was at iteration $ITERATION)."
else
  echo "No loop for THIS session (PID $CLAUDE_SESSION_PID)."
  echo "Use --all to cancel all loops."
fi
