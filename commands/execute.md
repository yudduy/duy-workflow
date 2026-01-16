---
description: Ralph-powered autonomous execution of SPEC.md with TDD
argument-hint: "[spec-path] [--max-iterations N]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*), Bash(git *)
---

# /execute

Execute a specification using a Ralph loop with subagent delegation.

## Usage

```bash
/execute                              # Uses docs/SPEC.md or finds latest in docs/specs/
/execute docs/specs/user-auth.spec.md # Execute specific spec
/execute --max-iterations 50          # Limit iterations (default: 100)
```

## Multi-Agent Mode

```bash
# Terminal 1                          # Terminal 2
/execute --agent-id 1                  /execute --agent-id 2
```

Each agent gets own worktree (`.worktrees/agent-{id}/`) and branch.

---

## Parse Arguments

```!
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"
echo "Spec: ${SPEC_PATH:-"(auto-detect)"} | Max iterations: $MAX_ITER"
```

## Prerequisites Check

```!
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

if [ -z "$SPEC_PATH" ] || [ ! -f "$SPEC_PATH" ]; then
  echo "❌ No spec file found. Run /interview first."
  exit 1
fi

echo "✅ Found: $SPEC_PATH"
head -20 "$SPEC_PATH" | grep -E "^#|^##|^\*\*" | head -10
```

## Worktree Setup (Multi-Agent Mode)

```!
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

if [ -n "$AGENT_ID" ]; then
  WORKTREE_DIR=".worktrees/agent-${AGENT_ID}"
  BRANCH_NAME="execution-agent-${AGENT_ID}"

  if [ -d "$WORKTREE_DIR" ]; then
    echo "✅ Worktree exists: $WORKTREE_DIR"
    echo "   Run: cd $(pwd)/$WORKTREE_DIR && claude"
  else
    git rev-parse --git-dir > /dev/null 2>&1 || { echo "❌ Not a git repo"; exit 1; }
    mkdir -p .worktrees
    git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" 2>&1 || \
      git worktree add "$WORKTREE_DIR" "$BRANCH_NAME" 2>&1 || \
      { echo "❌ Failed to create worktree"; exit 1; }
    mkdir -p "$WORKTREE_DIR/docs/specs"
    cp "$SPEC_PATH" "$WORKTREE_DIR/$SPEC_PATH"
    [ -f .env ] && cp .env "$WORKTREE_DIR/.env"
    echo "✅ Worktree: $WORKTREE_DIR | Branch: $BRANCH_NAME"
    echo "   Run: cd $(pwd)/$WORKTREE_DIR && claude"
  fi
  exit 0
fi

grep -E "COMPLETED|IN_PROGRESS|PENDING" "$SPEC_PATH" | head -5 || echo "No progress yet"
```

## Initialize Ralph Loop

```!
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

if [ -z "$AGENT_ID" ]; then
  "${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
    --max-iterations "$MAX_ITER" \
    --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
    "Implement $SPEC_PATH with TDD using subagent delegation.

## Your Role: ORCHESTRATOR
Delegate ALL implementation to subagents via Task tool. You don't write code.

## Each Iteration:
1. READ $SPEC_PATH for pending requirements
2. DELEGATE to backend-engineer or frontend-engineer subagents
3. VERIFY their work (tests pass)
4. DELEGATE code-simplifier to review and clean up the implementation
5. UPDATE progress in $SPEC_PATH

## Before Completion:
DELEGATE qa-engineer to verify everything (test coverage, edge cases, integration)

## Progress: Update directly in $SPEC_PATH
After verifying each requirement, update the progress table in the spec file:

| ID | Status | Notes |
|----|--------|-------|
| REQ-1 | COMPLETED | - |
| REQ-2 | IN_PROGRESS | - |

## Completion:
Run tests/build/lint, show output, then: <promise>ALL_REQUIREMENTS_VERIFIED</promise>
If blocked: <promise>BLOCKED: [reason]</promise>"
fi
```

## Anti-Circumvention Notice

```!
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

if [ -z "$AGENT_ID" ]; then
  echo "═══════════════════════════════════════════════════════════════════"
  echo "Promise: ALL_REQUIREMENTS_VERIFIED"
  echo ""
  echo "Only output promise when:"
  echo "  ✓ ALL requirements implemented with passing tests"
  echo "  ✓ Build + lint clean (show actual output)"
  echo ""
  echo "Do NOT output promise just because you're stuck or tired."
  echo "═══════════════════════════════════════════════════════════════════"
fi
```

---

## TDD Protocol

RED → GREEN → REFACTOR for each requirement.

---

## Verification Gate

Before completion, run and show output:
```bash
npm test && npm run build && npm run lint
```

---

## Completion

```
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
```

If blocked:
```
<promise>BLOCKED: [reason]</promise>
```
