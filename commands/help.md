---
description: Explain the Ralph Workflow plugin and available commands
---

# Ralph Workflow Plugin Help

Please explain the following to the user:

## The Workflow

This plugin provides a two-phase development workflow:

```
/interview  →  docs/SPEC.md  →  /execute  →  Done
```

1. **`/interview`** - Deep exploration + structured interview → outputs `docs/SPEC.md`
2. **`/execute`** - Ralph-powered autonomous implementation using TDD

## Primary Commands

### /interview

Deep codebase exploration combined with structured user interview.

**What it does:**
1. Explores your codebase thoroughly (using parallel exploration agents)
2. Web searches for domain best practices
3. Asks structured questions via AskUserQuestionTool
4. Generates comprehensive `docs/SPEC.md` with testable requirements

**Features:**
- Uses AskUserQuestionTool for structured multi-choice questions
- 2-4 questions per round
- Covers: Requirements, Constraints, Approach, Edge Cases, Verification
- Outputs testable requirements with completion criteria

---

### /execute [--max-iterations N]

Ralph-powered autonomous implementation with TDD enforcement.

**Prerequisites:**
- `docs/SPEC.md` must exist (run `/interview` first)

**What it does:**
1. Reads requirements from `docs/SPEC.md`
2. Initializes Ralph loop with stop hook
3. Each iteration: read progress → find next PENDING → TDD → commit
4. Tracks progress in `docs/PROGRESS.md`
5. Continues until all requirements verified

**Options:**
- `--max-iterations N` - Limit iterations (default: 100)

**Completion:** Outputs `<promise>ALL_REQUIREMENTS_VERIFIED</promise>` when done.

**TDD Protocol (enforced):**
```
RED → GREEN → REFACTOR → Commit
 │      │         │
 │      │         └─ Only refactor when GREEN
 │      └─ Write minimal code to pass
 └─ Write failing test FIRST
```

---

## Utility Commands

### /ralph-loop <PROMPT> [OPTIONS]

Start a raw Ralph loop (advanced use, typically use `/execute` instead).

**Usage:**
```
/ralph-loop "Refactor the cache layer" --max-iterations 20
/ralph-loop "Add tests" --completion-promise "TESTS COMPLETE"
```

**Options:**
- `--max-iterations <n>` - Max iterations before auto-stop
- `--completion-promise <text>` - Promise phrase to signal completion

### /cancel-ralph

Cancel an active Ralph loop by removing the state file.

---

## What is the Ralph Wiggum Technique?

The Ralph Wiggum technique is an iterative development methodology pioneered by Geoffrey Huntley.

**Core concept:**
```bash
while :; do
  cat PROMPT.md | claude-code --continue
done
```

The same prompt is fed to Claude repeatedly. The "self-referential" aspect comes from Claude seeing its own previous work in the files and git history.

**Each iteration:**
1. Claude receives the SAME prompt
2. Works on the task, modifying files
3. Tries to exit
4. Stop hook intercepts and feeds the same prompt again
5. Claude sees its previous work in files
6. Iteratively improves until completion

---

## Key Concepts

### Completion Promises

To signal completion, Claude outputs a `<promise>` tag:

```
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
```

The stop hook detects this and allows exit.

**Critical rule:** Promises must be TRUE. Do not output false promises to escape the loop.

### Progress Tracking

Progress is tracked in `docs/PROGRESS.md`:

```markdown
| ID | Requirement | Status | Notes |
|----|-------------|--------|-------|
| REQ-1 | [name] | COMPLETED | Verified |
| REQ-2 | [name] | IN_PROGRESS | - |
| REQ-3 | [name] | PENDING | - |
```

### Files Created

| File | Created By | Purpose |
|------|------------|---------|
| `docs/SPEC.md` | /interview | Requirements specification |
| `docs/PROGRESS.md` | /execute | Living progress tracking |
| `.claude/ralph-loop.local.md` | /execute | Ralph state (auto-managed) |

---

## When to Use This Workflow

**Good for:**
- New features with clear requirements
- Tasks requiring iteration and refinement
- Test-driven development projects
- Well-scoped implementation work

**Not good for:**
- One-shot operations
- Tasks requiring ongoing human judgment
- Exploration without clear goals
- Debugging production issues

---

## Learn More

- Original technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
- Claude Plugins Official: https://github.com/anthropics/claude-plugins-official
