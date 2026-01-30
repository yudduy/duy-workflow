# duy-workflow

Interview-driven spec generation and Ralph-powered autonomous execution for Claude Code.

## Installation

### One-liner (Recommended)

```bash
git clone https://github.com/yudduy/duy-workflow.git /tmp/duy-workflow && /tmp/duy-workflow/install.sh && rm -rf /tmp/duy-workflow
```

Then restart Claude.

### Via Marketplace (may fail on some systems)

```bash
/plugin marketplace add yudduy/duy-workflow
/plugin install duy-workflow@duy-workflow
```

Note: May fail with EXDEV error if `/home` and `/tmp` are on different filesystems. Use the one-liner above if this happens.

### Development Mode

```bash
claude --plugin-dir /path/to/duy-workflow
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/duy-workflow:research` | Deep research with optional `--map` for mind map generation |
| `/duy-workflow:interview` | Deep exploration + structured interview -> SPEC.md |
| `/duy-workflow:execute` | Ralph-powered TDD implementation |
| `/duy-workflow:commit-push-pr` | Quick commit, push, and PR creation |
| `/duy-workflow:ralph-loop` | Raw Ralph loop (advanced) |
| `/duy-workflow:cancel-ralph` | Cancel active loop |

---

## Quick Start

### For research:

```bash
# Deep research on a topic
/duy-workflow:research "transformer architectures"

# Research with auto-generated mind map
/duy-workflow:research "transformer architectures" --map
```

### For feature implementation:

```bash
# Step 1: Interview - explores codebase, asks structured questions, outputs SPEC.md
/duy-workflow:interview

# Step 2: Execute - Ralph loop implements the spec with TDD
/duy-workflow:execute
/duy-workflow:execute --max-iterations 50
```

### Quick commit workflow:

```bash
# Commit, push, and create PR in one command
/duy-workflow:commit-push-pr
/duy-workflow:commit-push-pr "Add user authentication"
```

---

## The Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   /research           →     /interview      →      /execute         │
│   ──────────                ──────────            ─────────         │
│   • Parallel agents         • Explore codebase    • Ralph loop      │
│   • Web search              • AskUserQuestion     • Reads SPEC.md   │
│   • KNOWLEDGE.md            • Web search          • TDD enforced    │
│   • --map for MINDMAP.md    • Output: SPEC.md     • PROGRESS.md     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Multi-Agent Execution

```bash
# Set up isolated worktrees
/duy-workflow:execute --agent-id 1
/duy-workflow:execute --agent-id 2

# Run in separate terminals
cd .worktrees/agent-1 && claude  # then: /duy-workflow:execute
cd .worktrees/agent-2 && claude  # then: /duy-workflow:execute
```

## Based On

- **Ralph Wiggum technique** by Geoffrey Huntley - autonomous iteration via stop hooks
- **Thariq's interview method** - deep spec generation via AskUserQuestionTool
- **TDD enforcement** - no code without failing test

## Learn More

- [Ralph Wiggum](https://ghuntley.com/ralph/)
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins)
