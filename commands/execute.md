---
description: Ralph-powered autonomous execution of a spec file with TDD
argument-hint: "[spec-path] [--max-iterations N] [--agent-id ID]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /execute

Execute a specification using a Ralph loop with subagent delegation.

## Usage

```bash
/execute docs/specs/user-auth.spec.md           # Execute specific spec
/execute --max-iterations 50                     # Limit iterations (default: 100)
/execute --agent-id 1                            # Multi-agent mode
```

## Multi-Agent Mode

```bash
# Terminal 1                          # Terminal 2
/execute --agent-id 1                  /execute --agent-id 2
```

Each agent gets own worktree (`.worktrees/agent-{id}/`) and branch.

---

## Locate Spec

```bash
ls docs/specs/*.spec.md 2>/dev/null || ls docs/SPEC.md 2>/dev/null || echo "No specs found in docs/specs/ or docs/SPEC.md"
```

If the user provided a spec path in their message, use that. Otherwise auto-detect from the listing above (most recently modified). If no spec found, ask the user.

## Initialize Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
  "You are an execution orchestrator. Find the spec file from conversation context or auto-detect it.

## SPEC DETECTION
1. If the user specified a spec path, use that
2. Otherwise: look for the most recent file in docs/specs/*.spec.md
3. If none found: look for docs/SPEC.md
4. If still none: ask the user via AskUserQuestion

Read the spec file. Extract all requirements (REQ-N items).

## Your Role: ORCHESTRATOR
Delegate ALL implementation to subagents via Task tool. You coordinate, you don't write code directly.

## Each Iteration:
1. READ the spec file for pending requirements
2. IDENTIFY the next incomplete requirement
3. DELEGATE to backend-engineer or frontend-engineer subagents with full context
4. VERIFY their work (run tests, check output)
5. DELEGATE code-simplifier to review and clean up the implementation
6. UPDATE progress in the spec file

## Progress Tracking
After verifying each requirement, update the progress table in the spec file:

| ID | Status | Notes |
|----|--------|-------|
| REQ-1 | COMPLETED | - |
| REQ-2 | IN_PROGRESS | - |

## Before Completion:
DELEGATE qa-engineer to verify everything (test coverage, edge cases, integration)

## Verification Gate:
Run the project's test/build/lint commands and show actual output.
Common patterns: npm test, pytest, cargo test, go test, make test
Detect from package.json, pyproject.toml, Cargo.toml, Makefile, etc.

## Completion:
When ALL requirements pass with tests + build + lint clean:
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
If blocked: <promise>BLOCKED: [reason]</promise>"
```

## Anti-Circumvention Notice

```!
echo "═══════════════════════════════════════════════════════════════════"
echo "Promise: ALL_REQUIREMENTS_VERIFIED"
echo ""
echo "Only output promise when:"
echo "  ✓ ALL requirements implemented with passing tests"
echo "  ✓ Build + lint clean (show actual output)"
echo ""
echo "Do NOT output promise just because you're stuck or tired."
echo "═══════════════════════════════════════════════════════════════════"
```

---

## TDD Protocol

RED -> GREEN -> REFACTOR for each requirement.

---

## Completion

```
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
```

If blocked:
```
<promise>BLOCKED: [reason]</promise>
```
