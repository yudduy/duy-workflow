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

## The Protocol (3 models, parallel dispatch, iterative convergence)

### Round 1: Parallel dispatch (all 3 in background)

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

### Round 2+: Cross-pollinate (each sees the others' findings)

Feed revised context + ALL findings to each. They must:
- Critique the others' positions
- Provide NEW evidence (not just restate)
- Explicitly say if they changed their mind and WHY
- Update confidence

### Convergence

**Consensus = ALL of these:**
- All 3 agree on the core answer with evidence (not mutual deference)
- All 3 confidence >= 70
- No unresolved contradictions
- Agreement backed by independent evidence (groupthink ≠ convergence)

**NOT consensus:**
- "I agree with Codex" without own investigation (deference, not convergence)
- All agree but none cite evidence (groupthink)
- Surface agreement but contradictory mechanisms

### Termination

- Consensus → proceed with the agreed position
- Deadlock (same positions 2 rounds, no new evidence) → apply Decision Precedence from plan, document the disagreement
- Max 3 rounds for decisions, max 5 for research conclusions
- Always log: what was decided, which models agreed, what the dissent was

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
