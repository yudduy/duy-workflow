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

When running multiple agents in parallel, use `--agent-id` to isolate each agent:

```bash
# Terminal 1                          # Terminal 2
/execute --agent-id 1                  /execute --agent-id 2
```

Each agent gets:
- Own git worktree: `.worktrees/agent-{id}/`
- Own branch: `execution-agent-{id}`
- Own Ralph state: `.claude/ralph-loop.local.md` (isolated in worktree)

Progress is tracked directly in the spec file itself (no shared PROGRESS.md).

---

## Parse Arguments

```!
# Parse arguments using helper script
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

echo "Configuration:"
echo "  Spec: ${SPEC_PATH:-"(auto-detect)"}"
echo "  Max iterations: $MAX_ITER"
```

## Prerequisites Check

```!
# Re-parse to get SPEC_PATH in this shell context
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

# Check for spec file
if [ -z "$SPEC_PATH" ] || [ ! -f "$SPEC_PATH" ]; then
  echo "❌ Error: No spec file found"
  echo ""
  echo "   Looked in:"
  echo "     - Provided path: ${SPEC_PATH:-"(none)"}"
  echo "     - docs/SPEC.md"
  echo "     - docs/specs/*.spec.md"
  echo ""
  echo "   Run /interview first to create a specification."
  exit 1
fi

echo "✅ Found: $SPEC_PATH"

# Show spec summary
echo ""
echo "Specification:"
head -20 "$SPEC_PATH" | grep -E "^#|^##|^\*\*" | head -10
```

## Worktree Setup (Multi-Agent Mode)

```!
# Parse arguments (each block runs in isolated shell context)
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

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
    echo "   Then run: /execute"
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
    # First try creating new branch, if branch exists, use existing
    if ! git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" 2>&1; then
      echo "Branch $BRANCH_NAME exists, using it..."
      if ! git worktree add "$WORKTREE_DIR" "$BRANCH_NAME" 2>&1; then
        echo "❌ Error: Failed to create worktree"
        exit 1
      fi
    fi

    # Copy spec file to worktree
    mkdir -p "$WORKTREE_DIR/docs/specs"
    cp "$SPEC_PATH" "$WORKTREE_DIR/$SPEC_PATH"

    # Copy .env if exists
    [ -f .env ] && cp .env "$WORKTREE_DIR/.env"
    [ -f .env.local ] && cp .env.local "$WORKTREE_DIR/.env.local"

    echo "✅ Worktree created: $WORKTREE_DIR"
    echo "✅ Branch: $BRANCH_NAME"
    echo "✅ Spec copied: $SPEC_PATH"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "NEXT STEPS FOR AGENT $AGENT_ID"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "   1. Open a NEW terminal"
    echo "   2. Run: cd $(pwd)/$WORKTREE_DIR && claude"
    echo "   3. In Claude: /execute $SPEC_PATH"
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

# Check for existing progress in spec file (single-agent mode)
echo ""
echo "📋 Current progress:"
grep -E "COMPLETED|IN_PROGRESS|PENDING" "$SPEC_PATH" | head -10 || echo "   No progress tracked yet"
```

## Initialize Ralph Loop

```!
# Parse arguments (each block runs in isolated shell context)
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

# Only run Ralph loop in single-agent mode (no --agent-id)
if [ -z "$AGENT_ID" ]; then
  "${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
    --max-iterations "$MAX_ITER" \
    --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
    "Implement $SPEC_PATH with TDD using subagent delegation.

## Your Role: ORCHESTRATOR
You are the orchestrator. You DO NOT write code directly.
You delegate ALL implementation work to subagents via the Task tool.

## CRITICAL RULES - READ CAREFULLY

### DO NOT USE docs/PROGRESS.md
- NEVER read docs/PROGRESS.md
- NEVER write to docs/PROGRESS.md
- NEVER create docs/PROGRESS.md
- Progress is tracked ONLY in the spec file itself

### Stay On Task
- You are implementing ONLY $SPEC_PATH
- ONLY read and write to $SPEC_PATH for progress
- IGNORE all other files named PROGRESS.md
- DO NOT switch to other tasks or phases

## Each Iteration:
1. READ: $SPEC_PATH (requirements AND progress status)
2. FIND: First PENDING requirement in the spec's progress table
3. DELEGATE: Use Task tool to spawn implementation subagent:
   - Subagent type: backend-engineer or frontend-engineer (as appropriate)
   - Give it the specific requirement to implement
   - Include relevant file paths and context
4. VERIFY: Check subagent's work (tests pass, code correct)
5. UPDATE: Mark requirement COMPLETED in $SPEC_PATH progress table
6. REPEAT: Until all requirements done

## Subagent Prompt Template:
\"Implement [REQ-X] from $SPEC_PATH.
Requirement: [copy requirement text]
Follow TDD: write failing test first, then implement, then refactor.
Relevant files: [list key files]
When done, ensure tests pass.\"

## Completion:
FINAL CHECK: All tests pass, build clean, lint clean
THEN: <promise>ALL_REQUIREMENTS_VERIFIED</promise>

If blocked: <promise>BLOCKED: [reason]</promise>"
fi
```

## Anti-Circumvention Notice

```!
# Parse arguments (each block runs in isolated shell context)
eval "$("${CLAUDE_PLUGIN_ROOT}/scripts/parse-execute-args.sh" $ARGUMENTS)"

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

**NEVER use docs/PROGRESS.md** - it causes conflicts when multiple specs run in parallel.

Progress is tracked **directly in the spec file itself** by adding a progress section at the bottom.

After each requirement, update the progress table at the bottom of YOUR spec file:

```markdown
---

## Execution Progress

| ID | Requirement | Status | Notes |
|----|-------------|--------|-------|
| REQ-1 | [name] | COMPLETED | [iteration notes] |
| REQ-2 | [name] | IN_PROGRESS | - |
| REQ-3 | [name] | PENDING | - |

**Started:** 2026-01-12
**Last Updated:** 2026-01-12
```

If the spec doesn't have a progress section yet, add one at the bottom.

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

1. **NEVER use docs/PROGRESS.md** - Progress goes in the spec file only
2. **SPEC is ground truth** - Read it each iteration (requirements + progress)
3. **Stay on YOUR spec** - Never switch to other specs or phases
4. **Orchestrate, don't implement** - Delegate to subagents via Task tool
5. **No code without failing test** - TDD always (subagents follow this)
6. **Verify before claiming** - Check subagent work, show actual output
7. **Update progress in spec** - Add/update progress table in the spec file
8. **Do not lie to exit** - Promise must be TRUE
