---
description: Cancel active Ralph Wiggum loop
argument-hint: "[--all | --list]"
allowed-tools: Bash
---

# Cancel Ralph

Cancel the Ralph loop for the current session, or manage all active loops.

## Usage

```bash
/duy-workflow:cancel-ralph           # Cancel this session's loop
/duy-workflow:cancel-ralph --list    # List all active loops
/duy-workflow:cancel-ralph --all     # Cancel ALL active loops
```

## Check Current Session

```!
# Get this session's PID
CLAUDE_SESSION_PID=$PPID
STATE_FILE=".claude/ralph-loop.${CLAUDE_SESSION_PID}.local.md"

# Parse arguments
LIST_ONLY=false
CANCEL_ALL=false
for arg in $ARGUMENTS; do
  case $arg in
    --list) LIST_ONLY=true ;;
    --all) CANCEL_ALL=true ;;
  esac
done

# List all active loops
echo "Active Ralph loops:"
FOUND_ANY=false
for f in .claude/ralph-loop.*.local.md 2>/dev/null; do
  if [[ -f "$f" ]]; then
    FOUND_ANY=true
    # Extract PID from filename
    LOOP_PID=$(echo "$f" | sed 's/.*ralph-loop\.\([0-9]*\)\.local\.md/\1/')
    ITERATION=$(grep '^iteration:' "$f" 2>/dev/null | sed 's/iteration: *//' || echo "?")
    MAX_ITER=$(grep '^max_iterations:' "$f" 2>/dev/null | sed 's/max_iterations: *//' || echo "?")
    STARTED=$(grep '^started_at:' "$f" 2>/dev/null | sed 's/started_at: *//' | tr -d '"' || echo "?")

    MARKER=""
    if [[ "$LOOP_PID" == "$PPID" ]]; then
      MARKER=" <-- THIS SESSION"
    fi

    echo "  - PID $LOOP_PID: iteration $ITERATION/$MAX_ITER (started: $STARTED)$MARKER"
  fi
done

if [[ "$FOUND_ANY" == "false" ]]; then
  echo "  (none)"
  echo ""
  echo "FOUND_LOOP=false"
  echo "LIST_ONLY=$LIST_ONLY"
  echo "CANCEL_ALL=$CANCEL_ALL"
  exit 0
fi

echo ""

# Handle --list flag
if [[ "$LIST_ONLY" == "true" ]]; then
  echo "FOUND_LOOP=true"
  echo "LIST_ONLY=true"
  echo "CANCEL_ALL=false"
  exit 0
fi

# Handle --all flag
if [[ "$CANCEL_ALL" == "true" ]]; then
  echo "CANCEL_ALL=true"
  echo "FOUND_LOOP=true"
  exit 0
fi

# Check for this session's loop
if [[ -f "$STATE_FILE" ]]; then
  ITERATION=$(grep '^iteration:' "$STATE_FILE" | sed 's/iteration: *//')
  echo "FOUND_LOOP=true"
  echo "ITERATION=$ITERATION"
  echo "STATE_FILE=$STATE_FILE"
  echo "LIST_ONLY=false"
  echo "CANCEL_ALL=false"
else
  echo ""
  echo "No loop for THIS session (PID $CLAUDE_SESSION_PID)"
  echo "Other sessions may have active loops (use --all to cancel all)"
  echo ""
  echo "FOUND_LOOP=false"
  echo "LIST_ONLY=false"
  echo "CANCEL_ALL=false"
fi
```

Check the output above:

1. **If FOUND_LOOP=false**:
   - Say "No active Ralph loop found."

2. **If LIST_ONLY=true**:
   - Just report the active loops shown above, no cancellation needed.

3. **If CANCEL_ALL=true**:
   - Use Bash: `rm -f .claude/ralph-loop.*.local.md`
   - Report: "Cancelled all Ralph loops"

4. **If FOUND_LOOP=true** (and not list/all):
   - Use Bash: `rm "$STATE_FILE"` (where STATE_FILE is from output above)
   - Report: "Cancelled Ralph loop for this session (was at iteration N)"
