# duy-workflow

Interview-driven spec generation, CLAUDE.md auto-generation, and Ralph-powered autonomous execution for Claude Code.

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
| `/duy-workflow:gen-claude-md` | Generate/update CLAUDE.md via parallel exploration agents |
| `/duy-workflow:interview` | Deep exploration + structured interview → SPEC.md |
| `/duy-workflow:execute` | Ralph-powered TDD implementation |
| `/duy-workflow:add-mistake` | Add anti-pattern to CLAUDE.md (compounding engineering) |
| `/duy-workflow:ralph-loop` | Raw Ralph loop (advanced) |
| `/duy-workflow:cancel-ralph` | Cancel active loop |
| `/duy-workflow:help` | Show documentation |

---

## Quick Start

### For new projects or onboarding:

```bash
# Generate CLAUDE.md from codebase exploration
/duy-workflow:gen-claude-md
```

### For feature implementation:

```bash
# Step 1: Interview - explores codebase, asks structured questions, outputs SPEC.md
/duy-workflow:interview

# Step 2: Execute - Ralph loop implements the spec with TDD
/duy-workflow:execute
/duy-workflow:execute --max-iterations 50
```

### When Claude makes a mistake:

```bash
# Add to anti-patterns so it doesn't happen again
/duy-workflow:add-mistake "Used deprecated API instead of new one"
```

---

## The Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   /gen-claude-md      →     /interview      →      /execute         │
│   ──────────────            ──────────            ─────────         │
│   • 5 parallel agents       • Explore codebase    • Ralph loop      │
│   • Discover patterns       • AskUserQuestion     • Reads SPEC.md   │
│   • Output: CLAUDE.md       • Web search          • TDD enforced    │
│                             • Output: SPEC.md     • PROGRESS.md     │
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

## Compounding Engineering

Every time Claude makes a project-specific mistake, add it to CLAUDE.md:

```bash
/duy-workflow:add-mistake "description of what went wrong"
```

Over time, Claude learns your project's gotchas and avoids repeating mistakes.

## Based On

- **Ralph Wiggum technique** by Geoffrey Huntley - autonomous iteration via stop hooks
- **Thariq's interview method** - deep spec generation via AskUserQuestionTool
- **TDD enforcement** - no code without failing test
- **Compounding engineering** - document mistakes to prevent repetition

## Learn More

- [Ralph Wiggum](https://ghuntley.com/ralph/)
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins)
