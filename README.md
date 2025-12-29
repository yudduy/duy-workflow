# duy-workflow

Interview-driven spec generation and Ralph-powered autonomous execution for Claude Code.

## Installation

### Standard Install (Recommended)

```bash
# 1. Add as marketplace
/plugin marketplace add yudduy/duy-workflow

# 2. Install the plugin
/plugin install duy-workflow@duy-workflow
```

### Manual Install (Fallback)

If standard install fails:

```bash
git clone https://github.com/yudduy/duy-workflow.git /tmp/duy-workflow
/tmp/duy-workflow/install.sh
rm -rf /tmp/duy-workflow
```

### Development Mode

```bash
claude --plugin-dir /path/to/duy-workflow
```

---

## Usage

```bash
# Step 1: Interview - explores codebase, asks structured questions, outputs SPEC.md
/duy-workflow:interview

# Step 2: Execute - Ralph loop implements the spec with TDD
/duy-workflow:execute
/duy-workflow:execute --max-iterations 50
```

---

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
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Commands

| Command | Description |
|---------|-------------|
| `/duy-workflow:interview` | Deep exploration + structured interview → SPEC.md |
| `/duy-workflow:execute` | Ralph-powered TDD implementation |
| `/duy-workflow:ralph-loop` | Raw Ralph loop (advanced) |
| `/duy-workflow:cancel-ralph` | Cancel active loop |
| `/duy-workflow:help` | Show documentation |

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
