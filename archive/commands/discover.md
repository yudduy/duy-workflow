---
description: Ralph-powered scientific discovery -- map the frontier, stress-test hypotheses, distill into incompressible principles. Produces vault-native knowledge.
argument-hint: "<problem-statement> [--knowledge PATH] [--team] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__deepwiki__ask_question
---

# /discover

Takes a problem. Maps the landscape exhaustively. Hunts for a robust hypothesis through adversarial stress-testing. Then distills the finding into incompressible first principles.

Output: ONE clean DISCOVERY.md. Working notes constrained to 4 fixed slots.

## Foundational Rigors (apply at every phase transition)

**Three-Question Audit** (`${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`):
1. **DELETION**: What is the minimum hypothesis that explains the observations? Kill decorative complexity.
2. **PRESENCE**: Go to the actual data/code/paper. Verify claims against source. Reproduce before citing.
3. **URGENCY**: Cheapest falsification first. Zero-cost checks before expensive experiments.

**Research Scaffold** (`${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`):
→ `gh search repos` → DeepWiki → alphaxiv (3 parallel) → clone significant repos → copy → scaffold.
Discovery starts with exhausting what others have already found. Don't rediscover known results.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
Every hypothesis, direction change, or conclusion → multi-model deliberation. Converge before presenting to user.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Exploration = sub-agents. Targeted reads = yourself. Heavy lifting = sub-agents. Decisions = yourself.

## Principles

1. **Evidence over reasoning.** Every claim grounded in something you found. WebSearch is not optional.
2. **Adversarial by default.** Every hypothesis gets attacked. Unattacked hypotheses are worthless.
3. **Grounded critiques only.** Flaws must have citations or logical contradictions. Vibes don't trigger refinement.
4. **Dead ends are findings.** What doesn't work narrows the search.
5. **The landscape first.** Map before you move.
6. **Compress ruthlessly.** The final output passes the incompressibility test. Every word load-bearing.
7. **Hard to vary over easy to vary.** Principles that survive variation are foundations. Principles that don't are your frontier.

## Multi-Model Tools

- **Search**: ask_alphaxiv (primary -- paper-grounded), Exa MCP (web_search_exa), WebSearch
- **Verify sources**: WebFetch on arxiv.org/html/{id}
- **Cross-verify + propose**: codex exec (peer review + abduction), gemini -p (adversarial + abduction)

**Codex is a persistent thinking partner** -- one session for the entire discovery, resumed each iteration:
- Accumulates understanding of the problem, landscape, dead ends, and hypotheses
- Can independently propose directions, critique hypotheses, and explore literature
- Session stored in TODO.md under `## Sessions`
- All calls use `codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check`
- Gemini has no session resume -- each `gemini -p` call is fresh. Keep gemini prompts self-contained.

## Setup

```bash
mkdir -p docs/discoveries/{topic-slug}/notes
find /tmp -maxdepth 1 -name 'claude-discover-*' -type d -mtime +1 -exec rm -rf {} + 2>/dev/null
WS=/tmp/claude-discover-$(openssl rand -hex 4)
mkdir -p $WS
echo "Workspace: $WS"
```

**All temp file paths use `$WS/` -- never hardcode `/tmp/codex-*.txt` or `/tmp/ralph-*.txt`.** Prevents stale reads across sessions.

### KG Survey (before researching)

Check what the vault already knows:

1. Read `Obsidian-Template-Vault/VAULT-INDEX.md` -- scan Distillations table and Knowledge Graph (MOCs)
2. Identify MOCs relevant to the topic (by title/domain match)
3. For each relevant MOC: read its `## Key Insights` section
4. For each relevant MOC: read its `## Questions to Explore` section
5. Compile:
   - KNOWN: claims already captured as insights (don't re-research these)
   - OPEN: questions explicitly listed as unresolved
   - GAPS: what's not covered by any existing MOC
6. Research ONLY what's in OPEN + GAPS

If `--knowledge` flag was provided, read the knowledge file and incorporate into landscape.

### Output Files

**DISCOVERY.md** -- The single readable artifact. Overwrite freely. Always reflects current best understanding.

```markdown
# Discovery: {Topic}
> Status: In Progress | Confidence: -- | Last updated: {timestamp}

## The Problem
[What are we trying to solve and why. One paragraph.]
[What is the REAL problem? The question behind the question.]

## The Landscape
[What exists today -- current SOTA, known limits, key researchers, failed approaches. Every claim CITED.]

## What We Found
[THE finding. The hypothesis that survived adversarial scrutiny.
3-7 sentences. Every word load-bearing. Every claim cited.]

## First Principles
{3-7 load-bearing truths extracted from the discovery. Each vary-tested.}

1. **Name** -- One sentence. [Source] ⬛ FOUNDATION -- hard to vary; negating breaks {what}
2. **Name** -- One sentence. [Source] ⬜ OPEN -- {what varies}; competing framings: {A vs B}

## Evidence
### Supporting
- [finding -- CITE source]

### Contradicting
- [counterpoint -- CITE source]

### Attacks Survived
- [specific adversarial critique it withstood -- what was claimed, why it held]

## Dead Ends
| Approach | Why It Failed | What We Learned |
|----------|---------------|-----------------|

## Contrarian Truth
{1-2 things most people get wrong about this. True but unpopular.}

## What Changes
[Concrete implications if this finding holds. What you'd build or do differently. Doable in 24 hours.]

## The Next Discovery
{Driven by the highest-value ⬜ OPEN principle above.
- Which OPEN principle this emerges from
- The competing framings that make it genuinely open
- What would resolve it -- experiment, evidence, or artifact}

## Sources
### Foundational (field-defining)
### Supporting (confirms hypothesis)
### Contrarian (strongest counterevidence)

## Summary
- **Status**: ACCEPTED | CANDIDATE | INCONCLUSIVE
- **Confidence**: HIGH | MEDIUM | LOW
- **Finding**: {one sentence}
- **First Principles**: {N} (⬛ {F}, ⬜ {O})
- **Attacks survived**: {N}
- **Dead ends**: {N}
- **Next discovery**: {frontier question from OPEN principle}
```

**TODO.md** -- Living roadmap. Both Claude and Codex read/update every iteration. NOT a frozen plan.

```markdown
# TODO: Discovery -- {Topic}

## Sessions
codex_session: {UUID}
alphaxiv_conversation: {ID}

## Current Phase
MAP LANDSCAPE | HYPOTHESIZE | STRESS-TEST | VALIDATE | DISTILL

## Active
- **Claude**: mapping SOTA via alphaxiv interrogation
- **Codex**: exploring cross-domain analogies independently

## Roadmap
Living plan. Add, remove, reorder as understanding deepens.

### Landscape
- [x] alphaxiv 3-pass interrogation -- Claude, iter 1
- [x] verify top 3 claimed mechanisms via WebFetch -- Claude, iter 2
- [x] Codex independent literature survey -- Codex, iter 1
- [ ] impossibility results and fundamental limits ← ACTIVE
- [ ] failed approaches survey

### Hypothesize
- [ ] Claude proposes 2-3 candidates
- [ ] Codex proposes 2-3 candidates (independent abduction)
- [ ] Gemini proposes 2-3 candidates
- [ ] Merge + triangulate → select

### Stress-Test
- [ ] Claude verifier (WebSearch for contradictions)
- [ ] Codex peer review (resume -- has full context)
- [ ] Gemini adversarial critique
- [ ] Triangulate verdicts
- [ ] Address critiques or PIVOT

### Validate
- [ ] alphaxiv: verify not rediscovering known work
- [ ] Recent papers check (last 6 months)
- [ ] Final multi-model review

### Distill
- [ ] Extract 3-7 principles
- [ ] Vary-test each (negate, swap, scope)
- [ ] Contrarian truth
- [ ] What Changes (doable in 24h)
- [ ] The Next Discovery
- [ ] Compress -- SHORTER not longer

## Amendments
Changes to the plan discovered during research:
- {iter N: added/removed/changed task because...}

## Dead Ends
| Iter | Approach | Why Failed | What We Learned |
|------|----------|-----------|----------------|

## Decisions
- {iter N: chose X over Y because...}

## Concerns
- {things that feel off -- flag before they become problems}
```

**Rules:**
- Both agents update TODO.md after every action
- When something feels wrong → add to Concerns, don't push through
- Every 5 iterations → "is the roadmap still right?"
- Codex reads TODO.md on every resume; Claude reads it at ORIENT

**notes/ -- 4 fixed slots. No other files.**

| File | Owner (team mode) | Purpose |
|------|-------------------|---------|
| `notes/landscape.md` | Scout | SOTA, known limits, key researchers, failed approaches, recent papers |
| `notes/evidence.md` | Scout + Critic | Supporting evidence AND contradicting evidence. Two sections. Citations required. |
| `notes/analogies.md` | Theorist | Cross-domain transfers, hypothesis reasoning, feasibility analysis |
| `notes/dead-ends.md` | Critic | What failed, why, what was learned. One entry per dead end. |

**Document Rules:**
1. DISCOVERY.md is the product -- overwrite freely
2. TODO.md is the shared roadmap -- both agents read/update every iteration
3. notes/ has exactly 4 files -- agents write to their slots, nowhere else
4. Every claim in DISCOVERY.md must have a citation
5. Rejected hypotheses get ONE ROW in Dead Ends table. Details in notes/dead-ends.md.

## Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
RALPH_PROMPT=$(mktemp /tmp/claude-discover-prompt-XXXXXX.txt)
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are a discovery agent with a persistent Codex thinking partner. Produce a DISCOVERY.md containing the finding that survived adversarial scrutiny, distilled into first principles. The problem statement is in the conversation context above.

## OUTPUT FILES

Write to docs/discoveries/{topic-slug}/:
- DISCOVERY.md -- the readable product
- TODO.md -- shared living roadmap (you + Codex both read/update)
- notes/landscape.md, notes/evidence.md, notes/analogies.md, notes/dead-ends.md

Do NOT create any other files in notes/.

## CODEX PARTNER

Initialize on first iteration via Bash tool:

    CODEX_OUTPUT=$(codex exec --json --full-auto --skip-git-repo-check \
      -o $WS/codex-discover.txt \
      'You are a persistent thinking partner for a discovery process.
       Problem: {problem statement}
       Your role: independently explore literature, propose directions, critique hypotheses.
       You will be resumed each iteration with new context. TODO.md is our shared roadmap.
       Start: what do you already know about this topic? What directions would you explore first?' 2>&1)
    CODEX_SESSION_ID=$(echo $CODEX_OUTPUT | grep 'thread.started' | jq -r '.thread_id')

Store in TODO.md under ## Sessions. All subsequent calls use: codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check

## TODO.md IS THE PLAN

Read TODO.md every iteration. Update after every action. The plan is a hypothesis -- amend it as understanding deepens. Add tasks, remove tasks, reorder. Every 5 iterations: 'is the roadmap still right?'

## ITERATION LOOP

No rigid phases. Follow TODO.md roadmap, but phases flow naturally:

### MAP LANDSCAPE (early iterations)

Before hypothesizing, understand what exists. Run in parallel:

**You (Claude):** alphaxiv 3-pass interrogation:
1. Landscape scan (new conversation): broad SOTA, key papers, known limits
2. Drill specifics (same conversation_id): mechanisms, pathologies, constraints
3. Adversarial pressure (same conversation_id): strongest arguments against, failures

**Codex (resume via Bash tool):**

    codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
      -o $WS/codex-landscape.txt \
      'Independent landscape survey for: {problem}. Use DeepWiki for relevant repos. Search broadly. What do YOU find that I might miss? Write findings -- I will merge into notes/landscape.md.'

**Task subagents:** impossibility results, failed approaches, cross-domain analogies

**⚠ ALPHAXIV HALLUCINATION WARNING**: Real paper IDs, FABRICATED mechanisms. After alphaxiv:
- WebFetch arxiv.org/html/{id} for top 2-3 claimed mechanisms
- Unverified → notes/dead-ends.md. Verified → notes/landscape.md.

Update TODO.md: check off completed items, add new leads discovered.

### HYPOTHESIZE (when landscape is mapped)

**Multi-model abductive reasoning** -- all three propose independently:

You: Generate 2-3 candidates from landscape + analogies.

Codex (resume -- already has landscape context, via Bash tool):

    codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
      -o $WS/codex-hypotheses.txt \
      'Based on everything we have explored so far, propose 2-3 hypotheses:
       1. What pattern suggests a non-obvious explanation? (abduction)
       2. What direction is not obvious from the landscape?
       3. What assumption is everyone taking for granted?
       For each: falsifiable statement, kill condition, first test.'

Gemini (fresh -- self-contained prompt, via Bash tool):

    gemini -p 'DIRECTION PROPOSAL
    Problem: {problem statement}. Known: {landscape summary}. Failed: {dead ends}.
    Propose 2-3 hypotheses. What would a contrarian bet on? What assumption might be wrong?
    For each: falsifiable statement + kill condition. Different perspective is the point.'

Merge: convergence = high prior, unique angles = investigate, contradictions = informative tension.
Update TODO.md with selected hypothesis and next steps.

### STRESS-TEST (when hypothesis selected)

**Multi-model cross-verification.** Three perspectives, disagreement = signal.

Claude: Delegate VERIFIER subagent (Task) -- WebSearch for contradictions, existing work, counterexamples. Write to notes/evidence.md.

Codex (resume -- remembers proposing the hypothesis, via Bash tool):

    codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
      -o $WS/codex-review.txt \
      'We selected hypothesis: {statement}. Kill criterion: {criterion}.
       Peer review: Is it falsifiable? Confounds? Simpler explanation? Weakest assumption?
       Be direct. You proposed alternatives earlier -- do you still think this is the best one?'

Gemini (via Bash tool):

    gemini -p 'ADVERSARIAL REVIEW. Hypothesis: {statement}. Assumptions: {list}. Evidence: {summary}.
    Find fatal flaws. Strongest argument AGAINST? Similar hypothesis that failed? What is naive?
    Be ruthless.'

Triangulate verdicts in notes/evidence.md. Disagreement protocol:
- All 3 ACCEPT → strong CANDIDATE
- All 3 REJECT → PIVOT (ask Codex + Gemini for new directions)
- 2v1 → investigate the disagreement
- All disagree → ill-posed, step back

Update TODO.md with verdict and next action.

### VALIDATE (when CANDIDATE)

1. alphaxiv: 'Has {our approach} been tried? Current SOTA?'
2. WebSearch recent papers (last 6 months)
3. Final multi-model round (via Bash tool):

   Codex:
       codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
         -o $WS/codex-final.txt \
         'FINAL REVIEW: Our conclusion is {statement}, confidence {N}. Key evidence: {summary}.
          You have been with this from the start. Is this justified? What caveats? What did we miss?'

   Gemini:
       gemini -p 'FINAL REVIEW: Hypothesis {statement}, confidence {N}. Evidence: {summary}.
       Grade A-F. What would make it stronger?'
4. All accept → ACCEPTED. Otherwise → refine or pivot.

### DISTILL (when ACCEPTED or best-effort)

Compress into first principles:
1. Extract 3-7 load-bearing truths from discovery + evidence
2. Vary-test each: NEGATE (decorative?), SWAP (alternative?), SCOPE (universal?)
3. Rate: ⬛ FOUNDATION or ⬜ OPEN
4. Contrarian truth -- true but unpopular
5. What Changes -- doable in 24 hours
6. The Next Discovery -- from highest-value ⬜ OPEN
7. COMPRESS -- DISCOVERY.md gets SHORTER, not longer

## SELF-CHECK (each iteration)
- Did I find genuinely new information?
- Did DISCOVERY.md get clearer (not just longer)?
- Am I making progress or spinning?
- Did I update TODO.md?
- Every 5 iterations: is the roadmap still right?
If last 2 iterations produced no meaningful improvement, distill with best result.

## QUALITY GATES

Before completing:
- [ ] Landscape maps the field with citations
- [ ] Hypothesis survived 2+ adversarial rounds (multi-model)
- [ ] Every claim in DISCOVERY.md has a citation
- [ ] Dead Ends captures what was ruled out and why
- [ ] First Principles with ⬛/⬜ annotations, at least 2 vary-tested
- [ ] 'What We Found' passes incompressibility test
- [ ] Contrarian Truth is genuinely contrarian AND evidenced
- [ ] 'What Changes' is doable in 24 hours
- [ ] 'The Next Discovery' traces to a specific ⬜ OPEN principle
- [ ] TODO.md reflects what actually happened (amendments, decisions, concerns addressed)

## COMPLETION

When the discovery is solid -- not when phases are done:
1. Update DISCOVERY.md with final state and honest confidence
2. Run KG Deposit:
   a. Write to vault: Obsidian-Template-Vault/3. Resources (Dynamic)/Distillations/Discovery - {Title}.md
      Frontmatter: tags (content/distillation, topics/{slug}), type: research, status: completed
   b. Extract 3-7 atomic insights -- Glob existing Insight - *.md first to avoid dupes
   c. Update or create MOC - {Topic}.md in 3. Resources (Dynamic)/
   d. Update MOC - Research Index.md with vault wikilinks
   e. Update VAULT-INDEX.md if new MOC or distillation
3. Clean up workspace: `rm -rf $WS`
4. <promise>DISCOVERY_COMPLETE</promise>

If stuck: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "$(cat "$RALPH_PROMPT")"
rm -f "$RALPH_PROMPT"
```

## Team Mode (--team flag)

When `--team` is specified, the Ralph loop lead dispatches Task subagents each iteration. No persistent agents -- the 4 note files carry state between iterations. Each subagent reads files, does work, writes to its assigned slot, returns.

### Subagent Prompts

The lead spawns these as needed via Task (run_in_background: true for parallel work):

**SCOUT** (model: sonnet, subagent_type: general-purpose):
```
You are a research scout. Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Read docs/discoveries/{topic}/notes/landscape.md for what's already mapped.
Your job: find what's MISSING from the landscape.

Tool priority:
1. ask_alphaxiv -- synthesized paper-grounded answers (use iterative 3-pass: landscape → drill → pressure test, reuse conversation_id)
2. Exa MCP (web_search_exa) -- semantic search
3. WebSearch -- broad search

⚠ alphaXiv returns REAL paper IDs but may FABRICATE specific mechanisms. After alphaxiv calls:
- Pick 2-3 most critical claimed mechanisms
- WebFetch arxiv.org/html/{paper_id} to verify
- Unverified claims → notes/dead-ends.md, not landscape

Write to TWO files ONLY:
- docs/discoveries/{topic}/notes/landscape.md -- append VERIFIED findings (SOTA, limits, researchers, papers)
- docs/discoveries/{topic}/notes/evidence.md -- Supporting section: evidence for current hypothesis
Do NOT create other files. Do NOT write to DISCOVERY.md.
Focus on: {lead's specific directive for this iteration}
```

**THEORIST** (model: opus, subagent_type: general-purpose):
```
You are a hypothesis theorist. Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md for current state.
Read docs/discoveries/{topic}/notes/landscape.md for the landscape.
Read docs/discoveries/{topic}/notes/evidence.md for current evidence.
Your job: {generate | refine | defend} hypothesis. Find cross-domain analogies.
Write to ONE file ONLY:
- docs/discoveries/{topic}/notes/analogies.md -- hypothesis reasoning, cross-domain transfers, feasibility
Do NOT create other files. Do NOT write to DISCOVERY.md.
{Lead's specific directive for this iteration}
```

**CRITIC** (model: opus, subagent_type: general-purpose):
```
You are an adversarial critic. Problem: {problem statement}
Read docs/discoveries/{topic}/DISCOVERY.md -- the current hypothesis.
Read docs/discoveries/{topic}/notes/evidence.md -- what evidence exists.
Your job: find flaws. WebSearch for contradicting evidence, existing work, counterexamples.

Also run multi-model critique via Bash:
- codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check "PEER REVIEW: {hypothesis}. Find confounds, simpler alternatives, weakest assumptions."
- gemini -p "ADVERSARIAL: {hypothesis}. Find fatal flaws, similar hypotheses that failed, what domain experts would call naive."
Log all three perspectives (yours + codex + gemini) in evidence.md.

Write to TWO files ONLY:
- docs/discoveries/{topic}/notes/evidence.md -- Contradicting section: counterevidence with citations + multi-model verdicts table
- docs/discoveries/{topic}/notes/dead-ends.md -- approaches that failed, why, learnings
Do NOT create other files. Do NOT write to DISCOVERY.md.
GROUNDING REQUIREMENT: Every critique must have a web citation or logical contradiction.
Rate each flaw 0-100 confidence. Verdict: REJECT / REVISE / ACCEPT.
{Lead's specific directive for this iteration}
```

### Lead Coordination

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
RALPH_LEAD_PROMPT=$(mktemp /tmp/claude-discover-lead-XXXXXX.txt)
cat > "$RALPH_LEAD_PROMPT" << 'PROMPT_EOF'
You are the discovery lead. Do NOT research or hypothesize yourself. You dispatch subagents + Codex and synthesize.

Each iteration:
1. Read TODO.md -- what's active, what's next, any concerns?
2. Read ALL 4 note files in docs/discoveries/{topic}/notes/
3. Read DISCOVERY.md
4. Decide what work is needed -- follow TODO.md roadmap, but adapt:
   - Landscape: spawn Scout + Codex (resume) in parallel
   - Hypothesize: spawn Theorist + Codex (resume for abduction) + gemini -p
   - Stress-test: spawn Critic + Codex (resume for peer review) + gemini -p
   - Validate: spawn Scout for recent papers + Codex (resume for final review)
   - Distill: spawn Theorist for vary-testing principles
5. Wait for agents. Synthesize ALL note files into DISCOVERY.md -- current beliefs only
6. Update TODO.md -- check off items, add new tasks, note decisions, flag concerns
7. Every 5 iterations: is the roadmap still right? Amend if not.

Codex is persistent -- resume the same session. It accumulates understanding.
Gemini is fresh each call -- self-contained prompts.

When stopping:
1. Update DISCOVERY.md with final state
2. Run KG Deposit (vault-native: write Discovery - {Title}.md to vault Distillations/, extract insights, update MOC, update Research Index with wikilinks not project paths)
3. <promise>DISCOVERY_COMPLETE</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-30}" \
  --completion-promise "DISCOVERY_COMPLETE" \
  "$(cat "$RALPH_LEAD_PROMPT")"
rm -f "$RALPH_LEAD_PROMPT"
```

### Token Efficiency
- Scout: Sonnet (search-heavy, cheaper)
- Theorist + Critic: Opus (deep reasoning)
- Codex: persistent session via `resume` (no re-sending context)
- Gemini: fresh each call (keep prompts self-contained)
- Subagents are stateless -- files carry context between iterations
- Spawn 2-3 subagents in parallel per iteration (run_in_background: true)
- Lead only synthesizes -- never searches or hypothesizes

## Output

```
Discovery complete: docs/discoveries/{topic-slug}/DISCOVERY.md
Vault deposit: Obsidian-Template-Vault/3. Resources (Dynamic)/Distillations/Discovery - {Title}.md
- Finding: {one sentence}
- Confidence: {HIGH|MEDIUM|LOW}
- First Principles: {N} (⬛ {F}, ⬜ {O})
- Attacks survived: {N adversarial rounds}
- Dead ends: {N}
- Contrarian truth: {one sentence}
- Next discovery: {frontier question from OPEN principle}
- Drill targets: {list of ⬜ OPEN principles}
```
