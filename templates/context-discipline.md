# Sub-Agent Context Discipline

Your context must last 100+ iterations. Be strategic about what enters it.

## Use sub-agents for BREADTH work:
- Searching/exploring codebases (Explore sub-agent)
- Broad research (WebSearch, alphaxiv, DeepWiki — spawn research sub-agents)
- Code review (spawn review sub-agent with taxonomy)
- Test writing (spawn test-writer sub-agent)
- Any task where you'd read 5+ files to find something

## Read files yourself for TARGETED work:
- Reading the specific file you're about to modify
- Reading the plan for constraint re-injection
- Reading TODO.md for progress tracking
- Reading a specific function/class you need for a decision
- Anything where you KNOW which file and WHY

## The principle:
Exploration = sub-agents (they search broadly, return what matters).
Targeted reads = yourself (you know exactly what you need).
Heavy lifting (research, review, testing) = sub-agents with fresh context.
Decisions and tracking = yourself.

## Orchestrator Role Definition

The Orchestrator's job is **synthesize findings from sub-agent reports and decide next direction**. That is the complete job description.

**Never**: read files for exploration. Never search broadly. Never accumulate raw results.

**The 3-file rule**: if you find yourself about to read 3 or more files to find something, that is Scout work. Spawn a subagent. The Orchestrator reads note files (landscape.md, evidence.md, etc.) — it does not go looking for things.

**Why this matters**: the Orchestrator's context must last 100+ iterations. Every exploratory read is context pollution that degrades decision quality at iteration 50+. Role clarity IS the enforcement — not a rule you follow, but a job description that makes the wrong action structurally alien.

Role discipline in the team:
- **Scout**: searches broadly, writes to KNOWLEDGE-MAP.md or notes/landscape.md
- **Theorist**: generates hypotheses, writes to UNDERSTANDING.md or notes/analogies.md
- **Critic**: invokes conjecture-review.md, writes to dead-ends
- **Orchestrator**: reads sub-agent outputs, synthesizes, decides next direction — nothing else

## Sub-agent dispatch:
1. Spawn with specific task + template prompt
2. Sub-agent gets fresh context (full budget for its task)
3. Sub-agent writes results to disk OR returns condensed summary
4. You read the summary and decide: proceed / fix / escalate

## Monitoring long-running processes (GPU training, experiments, deploys):

NEVER say "I'll check again in N minutes" without a concrete sleep+check command.

```bash
# CORRECT: actual monitoring
Bash(command="sleep 600 && nvidia-smi && tail -20 /path/to/training.log", timeout=660000)

# CORRECT: background monitoring while doing other work
Bash(command="sleep 600 && nvidia-smi && tail -20 /path/to/training.log", run_in_background=true, timeout=660000)

# WRONG: prose promise with no implementation
"I'll check again in 10 minutes to confirm stability."
```

Rules:
1. Every "I'll check in N min" MUST be attached to `sleep N*60 && check_cmd`
2. Use `run_in_background: true` if there's other work to do
3. Set `timeout: (N+1)*60*1000` to cover the sleep + check
4. Maximize resource utilization — if only using 50% VRAM, increase batch/M before sleeping
5. NEVER churn (repeated empty tool calls) when waiting — use sleep

## Why:
Your context at iteration 50 determines quality of iterations 51-100.
Exploratory reads pollute context with noise. Targeted reads add signal.
Sub-agents are disposable. Your context accumulates.
