# duy-workflow

A Claude Code plugin for interview-driven spec generation and Ralph-powered autonomous execution.

## Installation

```bash
# Clone to your plugins directory
git clone https://github.com/yudduy/duy-workflow.git ~/.claude/plugins/local/duy-workflow

# Or clone into a project for project-specific use
git clone https://github.com/yudduy/duy-workflow.git .claude-plugins/duy-workflow
```

Then enable in Claude Code: `/plugins` → enable `duy-workflow@local`

## The Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   /interview          →           /execute                         │
│   ───────────                     ─────────                         │
│   • Explore codebase              • Ralph loop (stop hooks)         │
│   • AskUserQuestionTool           • Reads SPEC.md                   │
│   • Web search best practices     • Full TDD enforcement            │
│   • Output: docs/SPEC.md          • Auto-documents in PROGRESS.md   │
│                                   • Embedded review at completion   │
│         ↓                         • Output: <promise>COMPLETE</p>   │
│    docs/SPEC.md ─────────────────→                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Commands

### /interview

Deep codebase exploration + structured interview → SPEC.md

**What it does:**
1. Explores codebase thoroughly (parallel agents)
2. Web searches for domain best practices
3. Asks structured questions via AskUserQuestionTool
4. Generates comprehensive `docs/SPEC.md`

**Key features:**
- Always uses AskUserQuestionTool (not plain text questions)
- 2-4 questions per round with multi-select or single-select
- Questions cover: Requirements, Constraints, Approach, Edge Cases, Verification
- Outputs testable requirements with completion criteria

### /execute

Ralph-powered autonomous implementation with TDD enforcement.

**What it does:**
1. Initializes Ralph loop with SPEC.md
2. Stop hook keeps Claude iterating automatically
3. Each iteration: read progress → identify next → TDD → commit
4. Documents progress in `docs/PROGRESS.md`
5. Completes when all requirements verified

**Options:**
```bash
/execute                       # Single agent, uses docs/SPEC.md
/execute --max-iterations 50   # Limit iterations (default: 100)
/execute --agent-id 1          # Multi-agent: set up worktree for agent 1
/execute --agent-id 2          # Multi-agent: set up worktree for agent 2
```

**Completion:** `<promise>ALL_REQUIREMENTS_VERIFIED</promise>`

### /ralph-loop (Advanced)

Start a raw Ralph loop for non-spec tasks. Use this when you want Ralph's iteration
without the structured `/interview` → `/execute` workflow.

```bash
/ralph-loop "Fix the auth bug" --max-iterations 20 --completion-promise "FIXED"
```

**Difference from /execute:**
- `/execute`: Spec-driven, TDD-enforced, progress-tracked, multi-agent ready
- `/ralph-loop`: Generic, manual configuration, raw Ralph power

### /cancel-ralph

Cancel an active Ralph loop.

```bash
/cancel-ralph
```

## TDD Enforcement

/execute enforces strict Test-Driven Development:

```
RED → GREEN → REFACTOR → Commit → Next
 │      │         │
 │      │         └─ Only when GREEN
 │      └─ Minimal code to pass
 └─ Test MUST fail first
```

**Iron Laws:**
1. NO code without failing test first
2. WebSearch before unfamiliar APIs
3. Verify before claiming (evidence required)
4. Update PROGRESS.md after each requirement

## Multi-Agent Execution

For parallel work, each agent runs in an isolated git worktree:

```bash
# Step 1: Set up worktrees (from main directory)
/execute --agent-id 1
/execute --agent-id 2

# Step 2: Run agents in separate terminals
# Terminal 1:
cd .worktrees/agent-1 && claude
# Then run: /execute

# Terminal 2:
cd .worktrees/agent-2 && claude
# Then run: /execute
```

Each agent has:
- **Isolated worktree**: `.worktrees/agent-{id}/`
- **Own branch**: `execution-agent-{id}`
- **Own PROGRESS.md**: Isolated in worktree
- **Own Ralph state**: Isolated in worktree
- **Shared SPEC.md**: Copied as read-only source

After completion:
```bash
# Review implementations
git diff main...execution-agent-1
git diff main...execution-agent-2

# Merge preferred implementation
git merge execution-agent-1

# Clean up
git worktree remove .worktrees/agent-1
git worktree remove .worktrees/agent-2
git branch -d execution-agent-1 execution-agent-2
```

## Files Created

| File | Created By | Purpose |
|------|------------|---------|
| `docs/SPEC.md` | /interview | Requirements specification |
| `docs/PROGRESS.md` | /execute | Living progress tracking |
| `.claude/ralph-loop.local.md` | Stop hook | Ralph state (auto-managed) |

## Based On

This plugin combines:
- **Ralph Wiggum technique** by Geoffrey Huntley - autonomous iteration via stop hooks
- **Thariq's interview method** - deep spec generation via AskUserQuestionTool
- **TDD enforcement** - no code without failing test

## Learn More

- Original Ralph: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
- Claude Plugins Official: https://github.com/anthropics/claude-plugins-official
