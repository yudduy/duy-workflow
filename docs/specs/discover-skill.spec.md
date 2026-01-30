# Specification: /discover Skill

> Use `/execute docs/specs/discover-skill.spec.md` to implement.

## Goal

A new Ralph-powered skill that drives an LLM through a structured hypothesis-propose-verify loop to discover novel insights on any domain, using adversarial verification and explicit cross-domain analogy search.

## Requirements

1. **[REQ-1]** Create `commands/discover.md` skill file with YAML frontmatter
   - Accepts arguments: `<problem-statement> [--knowledge PATH] [--max-iterations N] [--rigor formal|semi-formal|informal]`
   - `--knowledge` optionally loads a KNOWLEDGE.md from a prior `/research` run as starting context
   - `--rigor` defaults to `formal` for logic/proofs, `informal` for explanations
   - `--max-iterations` defaults to 30
   - Acceptance: Skill appears in Claude Code and can be invoked with `/duy-workflow:discover`

2. **[REQ-2]** Implement a 5-phase discovery pipeline in the skill prompt
   - **Phase 1: Problem Formulation** — Parse the problem, define scope, identify what "solution" looks like, establish evaluation criteria. If `--knowledge` provided, ingest it.
   - **Phase 2: Cross-Domain Analogy Search** — Explicitly map the problem's abstract structure (e.g., "distributed agreement under failure" maps to "voting theory", "Byzantine generals", "quorum systems in biology"). Use parallel Explore subagents to search for analogous solved problems in at least 3 unrelated fields.
   - **Phase 3: Hypothesis Generation** — Synthesize insights from Phase 2 into concrete hypotheses. Each hypothesis must include: (a) formal statement, (b) assumptions, (c) predicted consequences, (d) how to verify/falsify.
   - **Phase 4: Adversarial Verification** — Orchestrator delegates each hypothesis to a **verifier subagent** with an adversarial prompt: "Find flaws, counterexamples, or logical gaps in this hypothesis." Verifier critiques are fed back to the proposer.
   - **Phase 5: Refinement or Pivot** — Based on verifier feedback, either refine the hypothesis (fix flaws, strengthen arguments) or pivot to a new hypothesis. Track which hypotheses were attempted and why they were accepted/rejected.
   - Acceptance: All 5 phases execute in sequence within the Ralph loop. DISCOVERY.md contains evidence of each phase.

3. **[REQ-3]** Implement adversarial orchestrator-verifier pattern
   - The **proposer** is the main session (or a Task subagent).
   - The **verifier** is a separate Task subagent with a dedicated adversarial prompt: "You are a rigorous critic. Your job is to find flaws, counterexamples, unstated assumptions, and logical gaps. Do NOT confirm — only critique."
   - Verifier receives: the hypothesis, its formal statement, its proof/argument.
   - Verifier returns: list of flaws found (or "NO_FLAWS_FOUND" if it genuinely cannot find any).
   - Orchestrator decides: if flaws found → refine or pivot. If no flaws → mark hypothesis as candidate.
   - Acceptance: Verifier subagent is invoked at least once per iteration. Its critiques appear in DISCOVERY.md.

4. **[REQ-4]** Implement triple stop condition for the Ralph loop
   - **Condition A — Verifier accepts:** The verifier returns `NO_FLAWS_FOUND` for a candidate hypothesis on two consecutive checks (to avoid false acceptance).
   - **Condition B — Max iterations:** `--max-iterations` reached.
   - **Condition C — Diminishing returns:** The proposer detects it has generated 3+ hypotheses that are substantially similar to previous ones (self-assessed, logged in DISCOVERY.md).
   - The completion promise is `<promise>DISCOVERY_COMPLETE</promise>`.
   - The stop hook evaluates this promise as usual.
   - Acceptance: Loop terminates correctly under each of the three conditions. The reason for termination is logged.

5. **[REQ-5]** Output a structured `docs/discoveries/{topic}/DISCOVERY.md`
   - Structure:
     ```
     # Discovery: {Topic}
     ## Problem Statement
     ## Evaluation Criteria
     ## Cross-Domain Analogies
     | Source Domain | Analogous Concept | Mapping | Insight |
     ## Hypothesis Log
     ### Hypothesis 1: {name}
     - Status: ACCEPTED | REJECTED | REFINED → H3
     - Formal Statement: ...
     - Assumptions: ...
     - Argument/Proof: ... (formal logic for derivations, informal for explanations)
     - Verifier Critique: ...
     - Resolution: ...
     ### Hypothesis 2: ...
     ## Best Result
     - Hypothesis: ...
     - Confidence: HIGH | MEDIUM | LOW
     - Open Questions: ...
     ## Iteration Summary
     | # | Action | Hypothesis | Verifier Result | Decision |
     ```
   - Acceptance: File is created and contains all sections. Hypothesis log has at least one entry.

6. **[REQ-6]** Implement adaptive rigor based on `--rigor` flag and problem type
   - `formal`: Proofs use structured logic (premises → lemmas → conclusion), symbolic notation where helpful, explicit assumptions. Applied to mathematical derivations, algorithm correctness, protocol properties.
   - `semi-formal`: Structured arguments with clear reasoning chains but natural language. Applied to design arguments, trade-off analysis.
   - `informal`: Intuitive explanations, analogies, thought experiments. Applied to brainstorming, early exploration.
   - Default behavior: start `informal` in Phase 2 (analogy search), escalate to `formal` in Phase 4 (verification), regardless of flag. The flag controls Phase 3 (hypothesis generation).
   - Acceptance: DISCOVERY.md shows appropriate rigor level in each phase.

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Search strategy | Iterative refinement (Ralph loop) | User preference; simplest to implement; existing infrastructure |
| Verification | Adversarial subagent (orchestrator-verifier) | Catches blind spots LLM self-critique misses; no external tooling needed |
| Cross-domain | Explicit analogy phase with parallel Explore agents | Systematic rather than ad hoc; inspired by Mamba's control theory transfer |
| Output | DISCOVERY.md (structured markdown) | Consistent with KNOWLEDGE.md pattern from /research |
| Stop condition | Triple: verifier accepts + max iterations + diminishing returns | Robust termination; avoids infinite loops and premature stops |
| Rigor | Adaptive per phase, configurable per problem | Formal logic for proofs, informal for exploration; matches user preference |
| Integration | Standalone with optional /research input | Clean boundary; can use KNOWLEDGE.md but doesn't require it |

## Completion Criteria

- [x] `commands/discover.md` exists with correct YAML frontmatter and full prompt
- [x] 5-phase pipeline executes within Ralph loop
- [x] Adversarial verifier subagent is invoked and its output logged
- [x] Triple stop condition works (all three paths)
- [x] DISCOVERY.md is generated with all required sections
- [x] Adaptive rigor applied per phase
- [x] `--knowledge` flag correctly loads prior research
- [ ] Build + lint clean (shellcheck not available on this system; bash patterns match production skills)

## Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| Problem has no clear formal structure | Rigor adapts to `informal`; analogy phase still runs; verifier checks logical consistency rather than formal proof |
| Verifier always finds flaws (never accepts) | Diminishing returns or max iterations triggers stop; DISCOVERY.md notes best attempt with open flaws |
| `--knowledge` file doesn't exist | Error message; exit without starting loop |
| Cross-domain search finds no analogies | Log "no analogies found" and proceed to hypothesis generation from first principles |
| Hypothesis generation produces duplicates early | Diminishing returns counter increments; if 3+ duplicates, triggers stop condition C |
| User cancels mid-loop with /cancel-ralph | Normal cancellation; partial DISCOVERY.md preserved |

## Technical Context

### Key Files
- `commands/discover.md`: New skill definition (to create)
- `hooks/stop-hook.sh`: Existing Ralph loop mechanism (no changes needed)
- `scripts/setup-ralph-loop.sh`: Existing loop initialization (no changes needed)
- `commands/research.md`: Reference for Explore subagent patterns
- `commands/execute.md`: Reference for subagent delegation patterns

### Patterns to Follow
- YAML frontmatter for skill metadata (see `commands/research.md`)
- Parallel Explore subagents for Phase 2 (same pattern as `/research`)
- Task subagent with adversarial prompt for verifier (same delegation as `/execute` uses for backend-engineer)
- `docs/discoveries/{topic}/DISCOVERY.md` output path (mirrors `docs/research/{topic}/KNOWLEDGE.md`)
- Completion promise: `<promise>DISCOVERY_COMPLETE</promise>` (same mechanism as `ALL_REQUIREMENTS_VERIFIED`)
- Argument parsing via inline bash in the skill prompt (see `execute.md` pattern)
