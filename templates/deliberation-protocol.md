# Deliberation Protocol: Autonomous Multi-Model /collab

Every major decision triggers this protocol. Not optional. Not "consult if stuck." The DEFAULT is deliberation. Proceeding without it is the exception, not the rule.

## When to Trigger (automatically — don't wait for a prompt)

- Architecture or design decisions
- Choosing between approaches/libraries/patterns
- Research conclusions or interpretations
- Any output the user will see (plans, walkthroughs, reports)
- Any decision that's hard to reverse (API contracts, data models, schema choices)
- When confidence is below 80% on any claim
- When the answer seems "obvious" (obvious = untested = dangerous)

## When to SKIP (the exceptions)

- Pure mechanical tasks (formatting, renaming, file moves)
- Decisions the plan already made (just execute, don't re-litigate)
- Cost-limited operations where the decision is low-stakes and reversible

## The Protocol

### For major decisions: Autoreason Tournament

When the decision is hard to reverse, sycophancy risk is high, or the stakes are major → use the **Autoreason Tournament** (`${CLAUDE_PLUGIN_ROOT}/templates/autoreason-tournament.md`).

The tournament uses role isolation + blind evaluation + empirical convergence (incumbent wins 3 consecutive rounds from 3 independent judges). This is structurally honest — models cannot drift toward agreement because they never share context during production.

**When to use tournament**: architecture decisions, design choices, research conclusions, conjecture verdicts, any `/execute` DECIDE step.

### For routine deliberation: Parallel dispatch (single round)

When a quick multi-model check suffices (information-gathering, low-stakes reversible decisions, research verification) → use the parallel dispatch below.

**⚠ Role isolation still applies**: each model dispatches in parallel with fresh context. No cross-contamination.

**Codex** (via Bash, `run_in_background: true`, `timeout: 300000`):
```bash
codex exec -m gpt-5.4 --full-auto --skip-git-repo-check "{role}. {context}. {question}.
Research with your tools. Cite sources. Flag uncertainty. State your position.
Write findings to {output_path}. Last line: CONFIDENCE: [0-100]"
```

**Gemini** (via Bash, `run_in_background: true`, `timeout: 300000`):
```bash
gemini -m gemini-3.1-pro-preview -y -p "{role}. {context}. {question}.
Be contrarian. Challenge assumptions. Cite sources. Flag uncertainty.
End with CONFIDENCE: [0-100]" 2>&1 > {output_path}
```

**Claude subagent** (via Agent tool, `run_in_background: true`):
```
{role}. {context}. {question}.
Use WebSearch, alphaxiv, DeepWiki. Cite sources. Flag uncertainty.
Write findings to {output_path}. Last line: CONFIDENCE: [0-100]
```

### Convergence (parallel dispatch)

**Consensus = ALL of these:**
- All 3 agree on the core answer with evidence (not mutual deference)
- All 3 confidence >= 70
- No unresolved contradictions
- Agreement backed by independent evidence (groupthink ≠ convergence)

**NOT consensus:**
- "I agree with Codex" without own investigation (deference, not convergence)
- All agree but none cite evidence (groupthink)
- Surface agreement but contradictory mechanisms

**Termination:**
- Consensus → proceed
- Deadlock → apply Decision Precedence from plan; document the disagreement
- Max 1 round for routine checks; use tournament for anything that reaches round 2

## How to Log

In TODO.md Decisions section:
```
- iter N: {decision}
  - Codex: {position} (confidence: N%)
  - Gemini: {position} (confidence: N%)
  - Claude: {position} (confidence: N%)
  - Rounds: {N} | Status: {Consensus/Partial/Deadlock}
  - Rationale: {why this was chosen}
```

## Cost Awareness

Each round ≈ 3 API calls. If round 2 converges, stop. Don't run 5 rounds for a settled question. But NEVER skip round 1 for a major decision.
