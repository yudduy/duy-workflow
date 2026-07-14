#!/bin/bash
# review-loop.sh
# Adversarial review loop using claude -p + --resume.
# Launched automatically after execute completes. Runs entirely in background.
# Usage: review-loop.sh --cwd <path> --session-name <name> [--max-iterations N]

set -euo pipefail
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

CWD=""
EXECUTE_SESSION_NAME=""
MAX_ITER=10
LOG_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --cwd)            CWD="$2";                   shift 2 ;;
    --session-name)   EXECUTE_SESSION_NAME="$2";  shift 2 ;;
    --max-iterations) MAX_ITER="$2";              shift 2 ;;
    --log)            LOG_FILE="$2";              shift 2 ;;
    *) shift ;;
  esac
done

[[ -z "$CWD" ]]  && { echo "❌ --cwd required"; exit 1; }
[[ -z "$LOG_FILE" ]] && LOG_FILE="$CWD/.claude/review-${EXECUTE_SESSION_NAME}.log"

mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { echo "[$(date '+%H:%M:%S')] $*"; }

notify() {
  local title="$1" body="$2" sound="${3:-Glass}"
  if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$body\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
  fi
  # Also append to completed sessions log
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $title | $body" >> "$CWD/.claude/completed-sessions.log"
}

# ─── Build the review prompt ──────────────────────────────────────────────────
PLAN=$(ls -t "$CWD/.claude/plans/"*.md 2>/dev/null | head -1 || echo "")
PLAN_NAME=$(basename "${PLAN:-no-plan}" .md)

read -r -d '' REVIEW_PROMPT << 'PROMPT_EOF' || true
You are an adversarial reviewer. The user is away. Your job: find every flaw in the implementation before it reaches them.

## Your mandate

1. **Read the plan** — load `.claude/plans/*.md`. Extract every acceptance criterion and requirement. This is your ground truth.
2. **Read TODO.md** — understand what was built, decisions made, known concerns.
3. **Read the diff** — `git log --oneline -20` then `git diff main...HEAD` (or `git diff HEAD~$(git rev-list --count HEAD)..HEAD` if on main). Know exactly what changed.
4. **Run all validators** — tests, lint, types, build. Every failure is a blocker.
5. **Verify acceptance criteria** — for each requirement in the plan, verify it actually works. Not "code exists" — actually works.
6. **Adversarial probing**:
   - Try edge cases the tests don't cover
   - Look for reward hacking: tests modified to pass, hardcoded values, mock abuse
   - Check error paths, null handling, boundary conditions
   - Verify integration points actually connect (not just unit-tested in isolation)
   - Look for off-by-one errors, race conditions, silent failures
7. **Fix what you find** — don't just report. Fix bugs, add missing tests, harden edge cases. Commit fixes.
8. **Re-run validators after every fix** — fixes must not break what was passing.
9. **Write REVIEW.md** — findings, fixes applied, remaining concerns, confidence level.

## Completion gate

Only output `<promise>REVIEW_COMPLETE</promise>` when ALL of these are true:
- [ ] All tests pass (zero failures, zero skips that matter)
- [ ] Lint and types clean (zero warnings on changed files)
- [ ] Every acceptance criterion in the plan is verified working
- [ ] Adversarial probing found nothing unfixed
- [ ] REVIEW.md written with honest confidence level
- [ ] Any commits made pass the full test suite

If genuinely blocked (missing credentials, missing dependency, cannot proceed): output `<promise>REVIEW_BLOCKED: [specific reason]</promise>`

Do NOT output the promise just because "it looks good." Run the actual checks.

Start now: read the plan, read TODO.md, run tests, then systematically verify.
PROMPT_EOF

# ─── Start the review session ─────────────────────────────────────────────────
log "Starting adversarial review for session: $EXECUTE_SESSION_NAME"
log "Plan: ${PLAN_NAME}"
log "Max iterations: $MAX_ITER"
log "Log: $LOG_FILE"
echo ""

REVIEW_JSON=$(cd "$CWD" && claude -p "$REVIEW_PROMPT" \
  --output-format json \
  --dangerously-skip-permissions \
  2>/dev/null) || {
  log "❌ claude -p failed on initial call"
  notify "Review failed: $EXECUTE_SESSION_NAME" "claude -p failed to start review session" "Basso"
  exit 1
}

SESSION_ID=$(echo "$REVIEW_JSON" | jq -r '.session_id // empty')
RESPONSE=$(echo "$REVIEW_JSON"   | jq -r '.result    // empty')

if [[ -z "$SESSION_ID" ]]; then
  log "❌ No session_id in response"
  notify "Review failed: $EXECUTE_SESSION_NAME" "No session ID returned from claude -p" "Basso"
  exit 1
fi

log "Review session: $SESSION_ID"
echo "$RESPONSE" | tail -5
echo ""

# ─── Iterate ──────────────────────────────────────────────────────────────────
CONTINUE_PROMPT="Continue the adversarial review. Check what's still unverified. Run tests again. Fix any remaining issues. Only output <promise>REVIEW_COMPLETE</promise> when ALL acceptance criteria are verified and all validators pass. If blocked: <promise>REVIEW_BLOCKED: reason</promise>"

for i in $(seq 2 "$MAX_ITER"); do
  # Check for completion/block in last response
  if echo "$RESPONSE" | grep -q '<promise>REVIEW_COMPLETE</promise>'; then
    log "✅ Review complete at iteration $((i - 1))"
    break
  fi

  if echo "$RESPONSE" | grep -q '<promise>REVIEW_BLOCKED:'; then
    BLOCK_REASON=$(echo "$RESPONSE" | grep -o 'REVIEW_BLOCKED:[^<]*' | head -1 | sed 's/REVIEW_BLOCKED: *//')
    log "🛑 Review blocked: $BLOCK_REASON"
    notify "Review blocked: $EXECUTE_SESSION_NAME" "$BLOCK_REASON" "Basso"
    exit 1
  fi

  log "Iteration $i/$MAX_ITER — continuing review..."

  ITER_JSON=$(cd "$CWD" && claude -p "$CONTINUE_PROMPT" \
    --resume "$SESSION_ID" \
    --output-format json \
    --dangerously-skip-permissions \
    2>/dev/null) || {
    log "❌ claude -p --resume failed at iteration $i"
    notify "Review failed: $EXECUTE_SESSION_NAME" "claude -p --resume failed at iteration $i" "Basso"
    exit 1
  }

  SESSION_ID=$(echo "$ITER_JSON" | jq -r '.session_id // empty')
  RESPONSE=$(echo "$ITER_JSON"   | jq -r '.result    // empty')

  echo "$RESPONSE" | tail -3
  echo ""
done

# ─── Final check ──────────────────────────────────────────────────────────────
if ! echo "$RESPONSE" | grep -q '<promise>REVIEW_COMPLETE</promise>'; then
  log "⚠️  Max iterations ($MAX_ITER) reached without completion promise"
  notify "Review incomplete: $EXECUTE_SESSION_NAME" \
    "Hit max iterations. Attach to check: tmux attach -t ${EXECUTE_SESSION_NAME}" \
    "Basso"
  exit 0
fi

# ─── Notify user ──────────────────────────────────────────────────────────────
# Pull one-line summary from REVIEW.md if it exists
REVIEW_SUMMARY=""
if [[ -f "$CWD/REVIEW.md" ]]; then
  REVIEW_SUMMARY=$(grep -m1 '^- \|^## Confidence\|^Confidence' "$CWD/REVIEW.md" 2>/dev/null \
    | sed 's/^[#-]* *//' | cut -c1-120)
fi
[[ -z "$REVIEW_SUMMARY" ]] && REVIEW_SUMMARY="All acceptance criteria verified. Ready to review."

log "Sending completion notification"
notify "Review complete: $EXECUTE_SESSION_NAME" "$REVIEW_SUMMARY" "Glass"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Review complete. Notified."
echo ""
echo "  Read:  cat REVIEW.md"
echo "  Log:   cat $LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
