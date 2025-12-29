---
description: "Ralph-powered autonomous execution of SPEC.md with TDD"
argument-hint: "[--max-iterations N] [--agent-id N] [--setup-only]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh)", "Bash(git *)"]
hide-from-slash-command-tool: "true"
---

# /execute

Execute the specification in `docs/SPEC.md` using a Ralph loop.

## Multi-Agent Mode

When running multiple agents in parallel, use `--agent-id` to isolate each agent:

```bash
# Terminal 1                          # Terminal 2
/execute --agent-id 1                  /execute --agent-id 2
```

Each agent gets:
- Own git worktree: `.worktrees/agent-{id}/`
- Own branch: `execution-agent-{id}`
- Own progress file: `docs/PROGRESS.md` (isolated in worktree)
- Own Ralph state: `.claude/ralph-loop.local.md` (isolated in worktree)

SPEC.md is copied to each worktree as read-only source of truth.

---

## Parse Arguments

```!
# Parse arguments
MAX_ITER=100
AGENT_ID=""
SETUP_ONLY=false

ARGS_ARRAY=($ARGUMENTS)
for i in "${!ARGS_ARRAY[@]}"; do
  case "${ARGS_ARRAY[$i]}" in
    --max-iterations)
      MAX_ITER="${ARGS_ARRAY[$((i+1))]}"
      ;;
    --agent-id)
      AGENT_ID="${ARGS_ARRAY[$((i+1))]}"
      ;;
    --setup-only)
      SETUP_ONLY=true
      ;;
  esac
done

echo "Configuration:"
echo "  Max iterations: $MAX_ITER"
echo "  Agent ID: ${AGENT_ID:-"(single agent mode)"}"
echo "  Setup only: $SETUP_ONLY"
```

## Prerequisites Check

```!
# Check for SPEC.md
if [ ! -f "docs/SPEC.md" ]; then
  echo "❌ Error: docs/SPEC.md not found"
  echo ""
  echo "   Run /interview first to create a specification."
  echo ""
  echo "   The /execute command implements specifications autonomously."
  echo "   Without a spec, there's nothing to execute."
  exit 1
fi

echo "✅ Found docs/SPEC.md"

# Show spec summary
echo ""
echo "Specification:"
head -20 docs/SPEC.md | grep -E "^#|^##|^\*\*" | head -10
```

## Worktree Setup (Multi-Agent Mode)

```!
# Re-parse AGENT_ID for this block
AGENT_ID=""
SETUP_ONLY=false
ARGS_ARRAY=($ARGUMENTS)
for i in "${!ARGS_ARRAY[@]}"; do
  case "${ARGS_ARRAY[$i]}" in
    --agent-id) AGENT_ID="${ARGS_ARRAY[$((i+1))]}" ;;
    --setup-only) SETUP_ONLY=true ;;
  esac
done

if [ -n "$AGENT_ID" ]; then
  WORKTREE_DIR=".worktrees/agent-${AGENT_ID}"
  BRANCH_NAME="execution-agent-${AGENT_ID}"

  echo ""
  echo "═══════════════════════════════════════════════════════════════════"
  echo "MULTI-AGENT MODE: Agent $AGENT_ID"
  echo "═══════════════════════════════════════════════════════════════════"

  # Check if worktree already exists
  if [ -d "$WORKTREE_DIR" ]; then
    echo "✅ Worktree already exists: $WORKTREE_DIR"
    echo ""
    echo "   To run this agent, open a NEW terminal and execute:"
    echo ""
    echo "   cd $(pwd)/$WORKTREE_DIR && claude"
    echo ""
    echo "   Then run: /execute --max-iterations 100"
    echo ""
  else
    # Create worktree
    echo "Creating worktree for Agent $AGENT_ID..."

    # Ensure we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
      echo "❌ Error: Not in a git repository"
      echo "   Multi-agent mode requires git for worktree isolation."
      exit 1
    fi

    # Create worktrees directory
    mkdir -p .worktrees

    # Create worktree with new branch from current HEAD
    git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" 2>/dev/null || \
      git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"

    # Copy SPEC.md to worktree
    mkdir -p "$WORKTREE_DIR/docs"
    cp docs/SPEC.md "$WORKTREE_DIR/docs/SPEC.md"

    # Copy .env if exists
    [ -f .env ] && cp .env "$WORKTREE_DIR/.env"
    [ -f .env.local ] && cp .env.local "$WORKTREE_DIR/.env.local"

    echo "✅ Worktree created: $WORKTREE_DIR"
    echo "✅ Branch: $BRANCH_NAME"
    echo "✅ SPEC.md copied to worktree"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "NEXT STEPS FOR AGENT $AGENT_ID"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "   1. Open a NEW terminal"
    echo "   2. Run: cd $(pwd)/$WORKTREE_DIR && claude"
    echo "   3. In Claude: /execute --max-iterations 100"
    echo ""
    echo "   Each agent works in isolation. When done:"
    echo "   - Agent creates docs/RESULTS.md with summary"
    echo "   - Merge preferred implementation: git merge $BRANCH_NAME"
    echo "   - Clean up: git worktree remove $WORKTREE_DIR"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
  fi

  # If setup-only or agent-id specified, don't start Ralph loop here
  echo ""
  echo "⚠️  This session will NOT start a Ralph loop."
  echo "   Run Claude in the worktree directory for isolated execution."
  exit 0
fi

# Check for existing progress (single-agent mode)
if [ -f "docs/PROGRESS.md" ]; then
  echo ""
  echo "📋 Existing progress found:"
  grep -E "COMPLETED|IN_PROGRESS|PENDING" docs/PROGRESS.md | head -10
fi
```

## Initialize Ralph Loop (Single-Agent Mode)

```!
# Re-parse MAX_ITER for this block
MAX_ITER=100
AGENT_ID=""
ARGS_ARRAY=($ARGUMENTS)
for i in "${!ARGS_ARRAY[@]}"; do
  case "${ARGS_ARRAY[$i]}" in
    --max-iterations) MAX_ITER="${ARGS_ARRAY[$((i+1))]}" ;;
    --agent-id) AGENT_ID="${ARGS_ARRAY[$((i+1))]}" ;;
  esac
done

# Only run Ralph loop in single-agent mode
if [ -z "$AGENT_ID" ]; then
  "${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
    --max-iterations "$MAX_ITER" \
    --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
    "Implement docs/SPEC.md with TDD.

READ: docs/SPEC.md (requirements), docs/PROGRESS.md (done), git log -5 (recent)
FIND: First PENDING requirement
IMPLEMENT: Write failing test → implement → refactor → commit
UPDATE: Mark COMPLETED in PROGRESS.md
REPEAT: Until all requirements done

FINAL CHECK: All tests pass, build clean, lint clean
THEN: <promise>ALL_REQUIREMENTS_VERIFIED</promise>

If blocked: <promise>BLOCKED: [reason]</promise>"
fi
```

## Anti-Circumvention Notice

```!
# Only show in single-agent mode
AGENT_ID=""
ARGS_ARRAY=($ARGUMENTS)
for i in "${!ARGS_ARRAY[@]}"; do
  [ "${ARGS_ARRAY[$i]}" == "--agent-id" ] && AGENT_ID="${ARGS_ARRAY[$((i+1))]}"
done

if [ -z "$AGENT_ID" ]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════════════"
  echo "CRITICAL - Ralph Loop Completion Rules"
  echo "═══════════════════════════════════════════════════════════════════"
  echo ""
  echo "Completion promise: ALL_REQUIREMENTS_VERIFIED"
  echo ""
  echo "You may ONLY output <promise>ALL_REQUIREMENTS_VERIFIED</promise> when:"
  echo "  ✓ EVERY requirement in SPEC.md is implemented"
  echo "  ✓ EVERY requirement has a passing test"
  echo "  ✓ ALL tests pass (verified with actual output)"
  echo "  ✓ Build succeeds (verified with actual output)"
  echo "  ✓ Lint clean (verified with actual output)"
  echo ""
  echo "DO NOT output the promise if:"
  echo "  ✗ You think you're stuck"
  echo "  ✗ You've been running too long"
  echo "  ✗ The task seems impossible"
  echo "  ✗ You want to exit for any other reason"
  echo ""
  echo "The loop is designed to continue until GENUINE completion."
  echo "Trust the process. Do not lie to exit."
  echo "═══════════════════════════════════════════════════════════════════"
fi
```

---

## TDD Protocol

For each requirement, follow RED → GREEN → REFACTOR:

### RED: Write Failing Test First
```
1. Write test that describes expected behavior
2. Run test - it MUST fail
3. If test passes, you're testing existing behavior - rewrite
```

### GREEN: Minimal Implementation
```
1. Write simplest code to make test pass
2. No extras, no gold-plating
3. Verify test passes
```

### REFACTOR: Clean Up
```
1. Only refactor when tests are GREEN
2. Keep tests passing throughout
3. Commit when done
```

---

## Progress Tracking

After each requirement, update `docs/PROGRESS.md`:

```markdown
## Requirements Status

| ID | Requirement | Status | Notes |
|----|-------------|--------|-------|
| REQ-1 | [name] | COMPLETED | [iteration notes] |
| REQ-2 | [name] | IN_PROGRESS | - |
| REQ-3 | [name] | PENDING | - |
```

---

## Verification Gate

Before claiming completion, run and show output:

```bash
# Tests
npm test  # or pytest, go test, etc.

# Build
npm run build

# Lint
npm run lint
```

All must pass with actual output shown.

---

## Completion

When ALL requirements verified:

```
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
```

If genuinely blocked:

```
<promise>BLOCKED: [specific reason]</promise>
```

---

## Multi-Agent Completion

When running as an agent in a worktree:

1. Complete all requirements with passing tests
2. Create `docs/RESULTS.md` summarizing:
   - What was implemented
   - Test coverage achieved
   - Any deviations from spec
   - Recommended merge strategy

3. Output completion promise
4. User reviews and merges preferred implementation

---

## Iron Laws

1. **SPEC is ground truth** - Read it each iteration
2. **No code without failing test** - TDD always
3. **Verify before claiming** - Show actual output
4. **Update progress continuously** - State lives in files
5. **Do not lie to exit** - Promise must be TRUE
