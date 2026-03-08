---
description: Deep codebase exploration + structured interview to generate a spec file
argument-hint: "[feature description]"
---

# /interview

Generate a precise, verifiable SPEC.md through codebase exploration, reference discovery, and iterative refinement with the user.

**IMPORTANT:** This skill uses **plan mode**. Enter plan mode immediately at the start. Only exit plan mode once the spec is finalized and the user approves.

---

## STEP 0: ENTER PLAN MODE

**Immediately call `EnterPlanMode`** before doing anything else.

---

## PHASE 1: UNDERSTAND BEFORE ASKING

Before asking a single question, do three things in parallel:

### 1A: Know Your Codebase
- Read project CLAUDE.md (git repo root), `docs/HANDBOOK.md` if it exists
- Quick orientation: structure, entry points, how to run/test/build
- Grep for functionality related to what the user described — **does this already exist?**

### 1B: Know the World
- **Web search:** How have others built this? What are the established patterns?
- **DeepWiki:** For any GitHub projects relevant to this domain, ask how they implement it. Get architecture, key files, interfaces.
- **Libraries:** If a library might help, use DeepWiki to read its actual source. Don't guess APIs — read them. Evaluate extract-vs-import (Karpathy pattern).

### 1C: Dispatch Codex Explorer (in parallel with 1A + 1B)

Launch Codex to independently explore the codebase and research references:

```bash
CODEX_OUTPUT=$(codex exec --json --full-auto --skip-git-repo-check \
  -o /tmp/codex-interview-output.txt \
  "You are exploring a codebase to help design a feature: {USER'S FEATURE DESCRIPTION}.
   1. Read project CLAUDE.md and docs/HANDBOOK.md if they exist
   2. Find all code related to: {keywords from user's request}
   3. Search for reference implementations of similar features (use DeepWiki for GitHub repos)
   4. Summarize: what exists, what patterns to follow, what reference code to scaffold from
   5. List specific files and functions that would need modification" 2>&1)
CODEX_SESSION_ID=$(echo "$CODEX_OUTPUT" | grep '"thread.started"' | jq -r '.thread_id')
echo "Codex session: $CODEX_SESSION_ID"
```

Store `$CODEX_SESSION_ID` — resume this session throughout the interview and pass it to /execute.

### 1D: Present What You Found
Before interviewing, show the user:
1. "Here's what already exists in your codebase that's related: [X]"
2. "Here's how [project A] and [project B] solve this"
3. "I'd recommend scaffolding on [X]'s approach because [reason]"
4. "Codex independently found: [summarize /tmp/codex-interview-output.txt]"
5. "Here's what I think you want — correct me"

**Update project CLAUDE.md** with any discoveries (new patterns, gotchas, reference implementations).

---

## PHASE 2: ITERATIVE REFINEMENT

**Use AskUserQuestion tool** for all questions.

### The Core Loop

```
You propose what you THINK they mean (grounded in references)
  → User corrects or confirms
    → If corrects: SEARCH for what they corrected toward, re-propose
    → If confirms: move to next requirement
      → Repeat until user says "that's exactly it"
```

**This is NOT a 4-round questionnaire.** It's a conversation that continues until the spec is right. Some features take 2 rounds, some take 8. The user's confirmation is the exit condition, not a round count.

### What to Cover (naturally, not as a checklist)

- **Intent:** What problem does this solve? What does "done" look like?
- **Scope:** What's the MVP? What explicitly waits for v2?
- **Behavior:** For each capability, what exactly happens? (WHEN X, system SHALL Y)
- **Edges:** What happens when things go wrong?
- **Priority:** If you can only ship 3 things, which 3?

### Reactive Research

**When the user mentions something you can't ground in concrete knowledge, SEARCH IMMEDIATELY before your next question.** Two options:
1. Dispatch a Claude subagent to web search or DeepWiki
2. Resume Codex to investigate (it has DeepWiki + filesystem access):
   ```bash
   codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
     -o /tmp/codex-reactive.txt \
     "Research {topic the user just mentioned}. Find reference implementations, read their source code via DeepWiki. Report: architecture pattern, key interfaces, gotchas."
   ```

Then come back with: "You mean X like how [project] does it with [mechanism], or something different?"

Never ask "can you tell me more about X?" when you could search for X in 10 seconds.

### Duplication & MVP Guard

- **Before proposing any REQ:** Check if the codebase already has it
- **For every REQ:** Ask "is this needed for MVP or can it wait?"
- **Default to less.** Hardcode what could be configurable. Simplify what could be generic. Build the smallest useful thing.
- **If you catch yourself inventing REQs the user didn't ask for, stop.** The spec contains what they want, not what you think they should want.

---

## PHASE 3: SPEC GENERATION

**Output:** `docs/specs/{feature-name}.spec.md`

**The spec is a hypothesis, not a contract.** It captures our best understanding NOW. During /execute, implementation will reveal what we got wrong — REQs will be added, removed, amended. That's expected and healthy. The spec should be good enough to start building, not perfect enough to never change.

Every acceptance criterion uses EARS format:
- **WHEN** [event], the system **SHALL** [action]
- **IF** [condition], **THEN** the system **SHALL** [action]
- The system **SHALL NOT** [prohibition]

```markdown
# Specification: [Feature Name]

> To implement: `/duy-workflow:execute docs/specs/{this-file}.spec.md`
> This spec is a living document. /execute will amend it as implementation reveals reality.

## Goal
[One sentence — the problem, not the solution]

## Priority Stack
1. REQ-X (critical) — must ship
2. REQ-Y (critical) — must ship
3. REQ-Z (important)
4. REQ-W (nice-to-have)

## Reference Implementations
| Reference | What We're Using | Source | Notes |
|-----------|-----------------|--------|-------|
| [project] | [pattern/code] | [repo:file] | [extract vs import] |

## Requirements

### REQ-1: [Name]
**Priority:** critical | important | nice-to-have
**Scaffolding:** build from scratch | extract from [ref] | use [library]
**Acceptance (EARS):**
- WHEN [trigger], the system SHALL [behavior]
- IF [condition], THEN the system SHALL [alt behavior]
- The system SHALL NOT [prohibition]

**Verify in running system:**
- `[command to start]`
- Do: [action]
- Expect: [exact output/state]

### REQ-2: [Name]
...

## Design Decisions
| Decision | Choice | Rationale |

## Edge Cases
| Case | Expected Behavior | REQ |

## Out of Scope
- [excluded — with WHY]

## Deferred to v2
- [things intentionally simplified for MVP]

## Technical Context
- **Key files:** `[path]`: [purpose]
- **Patterns:** [from CLAUDE.md and codebase]
- **Reference code to read:** `[repo]:[file]` — [what to extract]
- **Run:** `[dev]` / **Test:** `[test]` / **Build:** `[build]`
```

---

## PHASE 4: VERIFY & SHIP

### Quick Audit
- [ ] Every REQ traces to something the user asked for (no agent-invented requirements)
- [ ] Every acceptance criterion is EARS format with no weasel words
- [ ] Every REQ has integration verification steps
- [ ] No duplication with existing codebase
- [ ] MVP-appropriate scope
- [ ] Reference implementations verified via DeepWiki (code actually exists)

### Codebase Check
Parallel subagents: one per REQ, verify implementability, identify exact files to modify, flag conflicts.

Also resume Codex for independent implementability review:
```bash
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  -o /tmp/codex-verify.txt \
  "Review this spec for implementability: {SPEC_PATH}.
   For each REQ: identify exact files to modify, flag conflicts with existing code, estimate complexity.
   Flag any REQ that contradicts existing patterns in CLAUDE.md."
```

### Present & Confirm
Show full spec to user. If they correct anything → update → re-present. Only proceed when confirmed.

### Update CLAUDE.md
Add patterns, gotchas, anti-patterns, and reference implementations discovered during this interview.

---

## HANDOFF

```
Spec: docs/specs/{feature-name}.spec.md
- [N] requirements, [M] scaffolded from references
- Priority: [top critical REQs]
- CLAUDE.md updated
- Codex session: $CODEX_SESSION_ID (carries codebase understanding into /execute)

To implement: /duy-workflow:execute docs/specs/{feature-name}.spec.md
```
