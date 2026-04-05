---
description: Pair with Codex as an autonomous peer -- both agents work the same repo, communicate async via message queue, debate decisions, and scaffold each other's work.
argument-hint: "<task-description> [--codex-task TASK]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content
---

# /pair -- Autonomous Peer Pairing

Launch a collaboration session where you (Claude Code) and Codex work the same repo as autonomous peers. Both agents independently make progress while communicating through an async message queue -- debating decisions, sharing specs, reviewing each other's work.

## Foundational Rigors (apply before and during pairing)

**Three-Question Audit** (`${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`):
1. **DELETION**: What is the minimum task split? Don't create artificial boundaries. Cut the work at natural seams.
2. **PRESENCE**: Each peer works on the actual code, not abstractions of it. Debate over diffs, not descriptions.
3. **URGENCY**: Ship incrementally. Don't wait for the other peer to finish. Push, communicate, iterate.

**Research Scaffold** (`${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`):
→ Both peers: before building, search for existing implementations → DeepWiki → copy → scaffold.
Neither peer should build from scratch when references exist. The message queue should share found references.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
Architecture disagreements between peers → both research independently, then debate over evidence. The pair IS deliberation. Convergence before either proceeds on a contested decision.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Exploration = sub-agents. Targeted reads = yourself. Heavy lifting = sub-agents. Decisions = yourself.

## Execution Steps

### Step 1: Parse the user's request

The user says `/pair <description>`. Parse:
- **Your task**: what YOU (Claude Code) should work on
- **Codex task**: what Codex should work on (if `--codex-task` given, use that; otherwise derive a complementary role -- e.g., if user says "build the auth module", Codex could research auth patterns and review)

If no args, ask: "What are we working on?"

### Step 2: Init session + drop AGENTS.md for Codex

Run this as a single bash block:

```bash
export PATH="$HOME/.claude/collab/bin:$PATH"
export COLLAB_AGENT=claude

# Init
collab-init $(pwd)
collab-join
COLLAB_AGENT=codex collab-join

# Drop AGENTS.md into repo so Codex reads it automatically
# (Codex reads AGENTS.md from repo root on startup)
cp ~/.claude/collab/AGENTS.md.template ./AGENTS.md

# Read protocol for Codex's initial prompt
PROTOCOL=$(cat ~/.claude/collab/COLLAB-PROTOCOL.md)

# Start Codex -- CAPTURE SESSION ID
cd $(pwd) && COLLAB_AGENT=codex codex exec --json --full-auto --skip-git-repo-check \
  "<PROMPT: you are 'codex', peer is 'claude', here's PROTOCOL, here's your task, setup env, check inbox, message claude you're online, start working>" \
  2>&1 | tee /tmp/codex-pair-init.json | grep -o '"thread_id":"[^"]*"' | head -1
```

Extract the session ID from output. Save to `/tmp/codex-session-id.txt`.

### Step 3: Start the watcher daemon

```bash
CODEX_SID=$(cat /tmp/codex-session-id.txt)
cd $(pwd) && nohup collab-watch codex "$CODEX_SID" 5 120 > /tmp/collab-watcher.log 2>&1 &
echo $! > /tmp/collab-watcher.pid
```

This keeps Codex alive -- polls inbox every 5s, heartbeat every 2min.

### Step 4: Send coordination message

```bash
export COLLAB_AGENT=claude
collab-send codex "I'm online. Working on: <your task>. You're on: <codex task>. Let's coordinate." --thread coordination
```

### Step 5: Start YOUR work

Now work on your task normally. The PostToolUse hook automatically checks your inbox every 10s. When you see a message from Codex:

1. Read it
2. Respond with `collab-send codex "reply" --thread <topic>`
3. Adapt your work if needed
4. Keep going

### Proactive messaging

While working, USE the collab tools when you:
- Hit a decision point → `collab-send codex "question" --thread <topic>`
- Make a breaking change → `collab-send all "heads up"`
- Finish something Codex needs → `collab-send codex "done with X, interface is Y"`
- Find an issue in shared code → tell Codex immediately
- Write a spec/schema → save to `/tmp/collab-session/shared/` and send with `--file`

### Cleanup

When done or user says stop:
```bash
kill $(cat /tmp/collab-watcher.pid 2>/dev/null) 2>/dev/null
echo "Session artifacts: /tmp/collab-session/shared/"
echo "Thread history: collab-thread <name>"
```

## Important

- You are PEERS. Neither is subordinate. Push back on bad ideas.
- Messages are ASYNC. Don't block waiting. Work on something else.
- The hook handles notifications. You don't need to manually poll.
- Codex has its own brain, web search, file access. Trust it to research independently.
- Thread history (`collab-thread <name>`) preserves full debates for reference.
- If Codex proposes something you disagree with, START A DEBATE. Use `--thread`.
