# duy-workflow

Research, spec generation, and Ralph-powered autonomous execution for Claude Code.

## Installation

### Fresh machine

```bash
git clone https://github.com/yudduy/duy-workflow.git ~/.claude/plugins/marketplaces/duy-workflow
~/.claude/plugins/marketplaces/duy-workflow/install.sh
```

Then restart Claude Code.

### From a temp clone

```bash
git clone https://github.com/yudduy/duy-workflow.git /tmp/duy-workflow && /tmp/duy-workflow/install.sh && rm -rf /tmp/duy-workflow
```

The installer copies files to a permanent location before the temp dir is removed.

### Development mode

```bash
claude --plugin-dir /path/to/duy-workflow
```

### Update

```bash
cd ~/.claude/plugins/marketplaces/duy-workflow && git pull
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/duy-workflow:research` | Autonomous experimental research with falsifiable conjectures |
| `/duy-workflow:interview` | Deep codebase exploration + structured interview -> SPEC.md |
| `/duy-workflow:execute` | Ralph-powered TDD implementation from spec |
| `/duy-workflow:discover` | Scientific discovery — map frontier, stress-test hypotheses |
| `/duy-workflow:distill` | Compress enduring questions into incompressible wisdom |
| `/duy-workflow:verify-poc` | Verify PoC code with frontier research recommendations |
| `/duy-workflow:pair` | Pair with Codex as autonomous peer via message queue |
| `/duy-workflow:derive` | Multi-model mathematical derivation swarm |
| `/duy-workflow:commit-push-pr` | Commit, push, and create PR in one command |
| `/duy-workflow:cancel-ralph` | Cancel active Ralph Wiggum loop |

---

## Quick Start

### Research

```bash
/duy-workflow:research "transformer architectures"
/duy-workflow:research "transformer architectures" --max-iterations 50
```

### Feature implementation

```bash
# Step 1: Interview - explores codebase, asks questions, outputs SPEC.md
/duy-workflow:interview

# Step 2: Execute - Ralph loop implements the spec with TDD
/duy-workflow:execute
/duy-workflow:execute --max-iterations 50
```

### Scientific discovery

```bash
/duy-workflow:discover "problem statement"
/duy-workflow:discover "problem statement" --team    # Scout + Theorist + Critic agents
```

### Mathematical derivation

```bash
/duy-workflow:derive "prove that ..."
```

### Quick commit

```bash
/duy-workflow:commit-push-pr
/duy-workflow:commit-push-pr "Add user authentication"
```

---

## The Workflow

```
/research     ->    /interview    ->    /execute
----------         ----------         ---------
Parallel agents    Explore codebase   Ralph loop
Web search         AskUserQuestion    Reads SPEC.md
Cross-verify       Output: SPEC.md   TDD enforced
Codex + Gemini     Codex review       Codex pair
```

## Multi-Agent Execution

```bash
/duy-workflow:execute --agent-id 1   # in terminal 1
/duy-workflow:execute --agent-id 2   # in terminal 2
```

## Based On

- **Ralph Wiggum technique** by Geoffrey Huntley — autonomous iteration via stop hooks
- **Thariq's interview method** — deep spec generation via AskUserQuestion
- **TDD enforcement** — no code without failing test
