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

## IMPORTANT: This skill is the entry point after clearing context

When users clear context and start a new session to implement a spec, `/execute` is the first command they run. This skill must be fully self-contained — it reads the spec file and has all the context it needs without relying on prior conversation.

## Locate Spec

```bash
ls docs/specs/*.spec.md 2>/dev/null || ls docs/SPEC.md 2>/dev/null || echo "No specs found in docs/specs/ or docs/SPEC.md"
```

If the user provided a spec path in their message, use that. Otherwise auto-detect from the listing above (most recently modified). If no spec found, ask the user.

**Also read the project CLAUDE.md** (at the git repo root) for patterns, anti-patterns, and conventions before starting execution.

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
Read the '## Execution Strategy' section to determine mode: solo, subagent, or team.
If no strategy section exists, default to 'subagent'.

---

## MODE: solo

Write code directly. No Task tool delegation.
Process REQs sequentially: RED test → GREEN implementation → REFACTOR.
Best for 1-3 simple REQs. Minimize overhead.

---

## MODE: subagent (default)

Delegate ALL implementation to subagents via Task tool. You coordinate, you don't write code directly.

Each Iteration:
1. READ the spec file for pending requirements
2. IDENTIFY the next incomplete requirement
3. DELEGATE to backend-engineer or frontend-engineer subagents with full context
4. VERIFY their work (run tests, check output)
5. DELEGATE code-simplifier to review and clean up the implementation
6. UPDATE progress in the spec file

---

## MODE: team

Use agent teams for parallel execution of independent REQ groups.

### Setup (first iteration only):
1. Read the REQ Groups table from the spec
2. Create a team: Teammate tool with operation 'spawnTeam', team_name from spec feature name
3. Create one TaskCreate per REQ group (include the REQs, target files, and acceptance criteria in the description)
4. Spawn one teammate per group via Task tool with team_name parameter:
   - subagent_type: backend-engineer or frontend-engineer (match the group's layer)
   - mode: 'plan' (require plan approval so you can gate before implementation)
   - Prompt: 'Read the spec at [path]. Implement [REQ-X, REQ-Y] using TDD. Claim your task from the task list.'
5. Keep teammate count <= number of REQ groups (never spawn more than needed)

### Coordination (subsequent iterations):
1. Check TaskList for completed/blocked tasks
2. Review and approve teammate plans (SendMessage with plan_approval_response)
3. If a teammate is stuck, send guidance via SendMessage
4. When all tasks complete, run verification gate yourself
5. Shutdown teammates (SendMessage with shutdown_request), then Teammate cleanup

### Token efficiency rules:
- Never broadcast when a direct message works
- Max 4 teammates (diminishing returns beyond that)
- Group small REQs together — don't spawn a teammate for a one-liner
- If only 2 REQ groups, prefer subagent mode unless each group is large (3+ REQs)

---

## Progress Tracking (all modes)
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
