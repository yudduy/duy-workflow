---
description: Autonomous engineering loop — execute a spec with principal engineer posture
argument-hint: "[spec-path] [--max-iterations N] [--agent-id ID]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /execute

Execute a specification autonomously. You are a **Principal Engineer** building toward the spec's goal. The user is the **Tech Lead** — they set direction, you execute without waiting for permission.

**The spec is a hypothesis, not a contract.** Implementation reveals what the spec got wrong. Your job is to build something that *actually works*, not to check off boxes. If a REQ is wrong, update it. If a new REQ is needed, add it. If the approach isn't working, pivot. TODO.md is a living document — both Claude and Codex continuously refine it as understanding deepens.

## Usage

```bash
/execute docs/specs/user-auth.spec.md           # Execute specific spec
/execute --max-iterations 50                     # Limit iterations (default: 100)
/execute --agent-id 1                            # Multi-agent mode
```

---

## LOCATE SPEC & LOAD CONTEXT

```bash
ls docs/specs/*.spec.md 2>/dev/null || ls docs/SPEC.md 2>/dev/null
```

Read (in parallel):
1. The spec file
2. Project CLAUDE.md (git repo root) — patterns, anti-patterns, past debugging lessons
3. `docs/HANDBOOK.md` if it exists
4. `TODO.md` if it exists (resume previous work)

If the spec has a `## Reference Implementations` section, use DeepWiki to read the referenced source code BEFORE writing any implementation code. Understand how the reference works, then scaffold on it.

### Initialize or Resume Codex Partner

Check TODO.md for an existing Codex session. Resume if found, start fresh if not.

```bash
EXISTING_SESSION=$(grep -oP 'codex_session: \K[a-f0-9-]+' TODO.md 2>/dev/null || echo "")

if [ -n "$EXISTING_SESSION" ]; then
  codex exec resume "$EXISTING_SESSION" --full-auto --skip-git-repo-check \
    -o /tmp/codex-output.txt \
    "Resuming. Read TODO.md — it's our shared roadmap. Check the Active section for your current task. If you finished your last task, check it off, pick the next unassigned one, and mark yourself active." 2>&1
  CODEX_SESSION_ID="$EXISTING_SESSION"
else
  CODEX_OUTPUT=$(codex exec --json --full-auto --skip-git-repo-check \
    -o /tmp/codex-output.txt \
    "You are a Principal Engineer pair-programming with Claude on a spec.
     Read the spec at {SPEC_PATH}. Read project CLAUDE.md. Read TODO.md if it exists.

     TODO.md is our shared roadmap. You and Claude both read and write to it.
     Your workflow each time you're called:
     1. Read TODO.md — find your active task or pick the next unassigned one
     2. Do the work (research, build, test, or review)
     3. Update TODO.md — check off completed items, note what you did, update Active section

     Start by reporting: which REQs exist, their priorities, what you'd take first." 2>&1)
  CODEX_SESSION_ID=$(echo "$CODEX_OUTPUT" | grep '"thread.started"' | jq -r '.thread_id')
fi

# Persist session ID in TODO.md
grep -q 'codex_session:' TODO.md 2>/dev/null \
  && sed -i '' "s/codex_session: .*/codex_session: $CODEX_SESSION_ID/" TODO.md \
  || echo -e "\n## Sessions\ncodex_session: $CODEX_SESSION_ID" >> TODO.md
```

---

## THE ENGINEERING LOOP

Execute this loop continuously. Each iteration produces **committed, tested, working code.**

```
┌──────────────────────────────────────────────────────────┐
│                   ENGINEERING LOOP                        │
│                                                          │
│  1. ORIENT    — Read spec + TODO.md. What's next?        │
│                 What broke last time? Re-read the EARS   │
│                 criteria for the current REQ.            │
│                 Every 5 iters: is the roadmap still      │
│                 right? Are we building the right thing?   │
│      ↓                                                   │
│  2. RESEARCH  — Before coding: DeepWiki the reference    │
│                 implementation. Web search if unsure.     │
│                 Read the actual API docs, don't guess.    │
│      ↓                                                   │
│  3. BUILD     — Implement. Small diffs. One REQ at a    │
│                 time. Scaffold on reference code.         │
│                 Commit frequently.                        │
│      ↓                                                   │
│  4. TEST      — Run ALL tests. Not just new ones.        │
│                 If no tests exist, write them FIRST.      │
│      ↓                                                   │
│  5. DEBUG     — If tests fail: REPRODUCE → ISOLATE →     │
│                 UNDERSTAND → FIX → VERIFY → DOCUMENT.    │
│                 No shotgun debugging.                     │
│      ↓                                                   │
│  6. VERIFY    — Three gates per REQ:                     │
│                 Gate 1: Tests pass                        │
│                 Gate 2: Every EARS criterion has a test   │
│                 Gate 3: Integration verification —        │
│                         run the system, check behavior    │
│      ↓                                                   │
│  7. COMMIT    — Clean commit. Update progress.           │
│      ↓                                                   │
│  (back to 1, next REQ by priority)                       │
└──────────────────────────────────────────────────────────┘
```

**Golden rule**: Never move past BUILD without passing TEST. The loop is: `build → test → debug → test → debug → test → (green) → verify → review → commit`.

**Process REQs in Priority Stack order** (critical first), not REQ number order.

### Work Splitting with Codex

For specs with 4+ REQs, split work between Claude and Codex:

**Assignment strategy:**
- **Claude takes**: core architecture, complex integrations, files with many dependencies
- **Codex takes**: self-contained REQs, utility modules, test scaffolding, reference extraction
- **NEVER** assign the same files to both simultaneously

To assign a REQ to Codex:
```bash
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  -o /tmp/codex-build.txt \
  "Implement REQ-N: {name}.
   EARS criteria (verbatim from spec):
   - WHEN {trigger}, the system SHALL {behavior}
   Patterns from CLAUDE.md: {relevant patterns}
   Files to modify: {list}
   Write tests FIRST, then implement. Commit when green."
```

**IMPORTANT:** After Codex implements, YOU must verify independently. Never trust agent success reports.

### Mutual Code Review

After each REQ implementation, the other party reviews.

**When YOU implemented — dispatch Codex to review:**
```bash
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  -o /tmp/codex-review.txt \
  "Code review for REQ-N: {name}.
   Run: git diff HEAD~1
   Check against EARS criteria: {paste criteria}
   Check for: correctness, edge cases, pattern violations (see CLAUDE.md), test coverage gaps.
   Format: APPROVE / REQUEST_CHANGES with specific file:line feedback."
```

**When CODEX implemented — you review:**
1. `git diff` to see what Codex changed
2. Read each modified file
3. Verify against EARS criteria
4. Run the tests yourself
5. If issues: dispatch fix via `codex exec resume $CODEX_SESSION_ID`

No REQ is DONE until reviewed by the other party.

---

## INITIALIZE RALPH LOOP

```!
cat > /tmp/ralph-execute-prompt.txt << 'PROMPT_EOF'
You are a Principal Engineer executing a spec autonomously.

## SPEC DETECTION
1. If the user specified a spec path, use that
2. Otherwise: most recent file in docs/specs/*.spec.md
3. If none: docs/SPEC.md
4. If none: ask via AskUserQuestion

Read the spec. Read project CLAUDE.md (including anti-patterns/gotchas — don't repeat past mistakes). Read TODO.md if it exists.

If the spec has Reference Implementations, use DeepWiki to read the actual source code before implementing. Understand the reference, then scaffold on it. COPY BEFORE REWRITE — never rewrite from memory.

## THE SPEC IS A HYPOTHESIS

The spec is your starting point, not your prison. Implementation reveals truth that planning cannot.

- If a REQ doesn't work as specified → amend it in TODO.md AND the spec file
- If you discover a missing requirement → add it to TODO.md and the spec
- If a REQ is redundant or wrong → strike it from TODO.md, note why in Spec Amendments
- If the approach needs to pivot → document the pivot in Decisions, update the roadmap
- Every 5 iterations → step back and ask: Is the roadmap still right? Are we building the right thing?
- If concerns are accumulating → escalate to user. Don't grind through a bad plan.

Your job is not to check boxes. Your job is to build something that actually works.

## EXECUTION MODE

Assess the spec scope:
- 1-3 REQs, same files → work directly (no delegation overhead)
- 4+ REQs or multiple layers → split between Claude + Codex + subagents

For subagent delegation:
1. RE-READ the spec (check for updates from previous iterations)
2. IDENTIFY next incomplete REQ by priority
3. If reference code exists for this REQ: read it via DeepWiki first
4. DELEGATE with full context: EARS criteria verbatim, files to modify, patterns from CLAUDE.md
5. VERIFY their work independently (never trust agent success reports)
6. UPDATE progress

## CODEX PAIR PROGRAMMING

On first iteration: initialize Codex session (see LOCATE SPEC section). On subsequent iterations: resume using session ID from TODO.md.

### Work Splitting Rules
- Assess each REQ: is it self-contained enough for Codex?
- Codex gets: utility modules, test scaffolding, reference extraction, simple CRUD, isolated features
- Claude keeps: core architecture, complex integrations, cross-cutting concerns
- NEVER assign same files to both simultaneously — check TODO.md Active section
- When assigning Codex a task, tell it to update TODO.md when done — check off items, update Active

### Review Protocol
- After you finish a REQ → dispatch Codex review → read output → address feedback → then mark DONE
- After Codex finishes a REQ → git diff → read changes → verify tests → provide feedback → then mark DONE
- No REQ is DONE until reviewed by the other party

### TODO.md is the Shared Roadmap
- Both agents read TODO.md at the start of every iteration
- Both agents update it after every action (check off items, move Active, add notes)
- Session IDs stored in Sessions section of TODO.md
- Decisions and debugging notes accumulate for later CLAUDE.md update
- Always use codex exec resume $SESSION_ID — never start fresh mid-execution

## THE THREE VERIFICATION GATES (per REQ)

All three must pass. Not one. Not two. All three.

### Gate 1: Tests Pass
Run test command, show output. Green or no proceed.

### Gate 2: EARS Coverage
Re-read the EARS criteria. For EACH criterion:
- WHEN [trigger] → test exists for this trigger
- SHALL [behavior] → test asserts this behavior
- SHALL NOT [prohibition] → test proves this doesn't happen
- IF [condition] → both branches tested

Missing criterion = missing test = REQ not done.

### Gate 3: Integration Verification
Read the spec's integration verification steps for this REQ.
Start the system. Perform the action. Compare actual vs expected.
If no integration steps in spec: write them yourself, then run them.

Unit tests prove code logic. Integration proves the feature works.

## TODO.md — LIVING ROADMAP

TODO.md is the single source of truth. Both Claude and Codex read it every iteration and **continuously refine it**. Initialize from the spec's Priority Stack, then evolve as implementation reveals reality.

**This is NOT a frozen checklist.** It's a living plan that gets smarter every iteration:
- **Add tasks** when you discover something the spec missed
- **Remove/modify tasks** when a REQ turns out to be wrong or unnecessary
- **Split tasks** when one turns out to be bigger than expected
- **Reorder priorities** when implementation reveals dependencies the spec didn't anticipate
- Add a Spec Amendments section when reality contradicts the spec — update the spec file too
- **Flag concerns** when something feels off — don't just grind through it

TODO.md template (create this file at the start):

    # TODO: {Spec Name}

    ## Sessions
    codex_session: {UUID}

    ## Roadmap
    Initialized from spec. LIVING — add, remove, reorder as understanding deepens.

    ### REQ-1: {Name} [critical]
    - [x] Research: read reference implementation — Claude, iter 1
    - [x] Build: implement core logic — Claude, iter 2
    - [x] Test: write EARS tests (3/3 criteria) — Claude, iter 2
    - [x] Review: Codex APPROVED — iter 3
    - [x] Verify: Gate 3 integration — Claude, iter 3

    ### REQ-2: {Name} [critical] — REVISED iter 4: pivoted to {new approach}
    - [x] Research: extract pattern from {ref} — Codex, iter 2
    - [x] Build: implement utility module — Codex, iter 3
    - [ ] Build: new approach using {X} — Codex, iter 5
    - [ ] Test: missing SHALL NOT test — Codex, iter 6 — ACTIVE
    - [ ] Review: Claude pending
    - [ ] Verify: Gate 3

    ### REQ-NEW: {Discovered during implementation} [important]
    - [ ] Added iter 4: found during REQ-2 that we also need {X}

    ## Active
    - Claude: REQ-4 BUILD — implementing auth middleware
    - Codex: REQ-2 TEST — adding negative test for SHALL NOT

    ## Blocked
    - REQ-5: waiting on external API key

    ## Spec Amendments
    - iter 3: REQ-3 removed — duplicate of REQ-1 edge case
    - iter 4: REQ-2 approach changed — original pattern doesnt work with {constraint}
    - iter 4: REQ-NEW added — missing requirement discovered during integration

    ## Decisions
    - iter 2: chose extract-over-import for {lib} because {reason}
    - iter 3: Codex review caught missing edge case in REQ-1, fixed

    ## Concerns
    - {thing that feels off but isnt blocking yet}

    ## Debugging Notes
    - {pattern that broke and how it was fixed}

**Rules:**
- Both agents update TODO.md after every action — check off, add, remove, amend
- When taking a task: mark it with your name + iteration
- When something feels wrong: add to Concerns section, don't just push through
- When the spec is wrong: add to Spec Amendments AND update the spec file
- When Codex is dispatched: tell it to update TODO.md with its progress
- Claude reads TODO.md at ORIENT step; Codex reads it at session start/resume
- Blocked items get escalated to user via AskUserQuestion
- **Every 5 iterations**: step back and ask — is the roadmap still right? are we building the right thing?

## DEBUGGING PROTOCOL

When something breaks:
1. REPRODUCE — minimal test that triggers the failure
2. ISOLATE — binary search: which component/line?
3. UNDERSTAND — WHY does it fail? Trace the data flow.
4. FIX — minimum change, proportional to the bug
5. VERIFY — reproducer passes, full suite green, no regressions
6. DOCUMENT — add reproducer as permanent test, update CLAUDE.md anti-patterns section with what went wrong and the debug approach that worked

After 3 failed attempts on same issue: STOP. Re-read from scratch. Write your understanding to the Debugging Notes section of TODO.md. The bug is usually a wrong assumption.

## WHEN TO NOTIFY THE TECH LEAD
- Milestone gate passed (brief: 'REQ-1 done, moving to REQ-2')
- Architecture-level decision with trade-offs
- Blocked by external dependency or access
- The approach won't work, need to pivot

Do NOT ask permission for implementation decisions within scope. Build, commit, they'll redirect.

## POST-IMPLEMENTATION

After all REQs pass all gates:
1. Update project CLAUDE.md with everything learned: gotchas, patterns, anti-patterns, debugging approaches that worked
2. Update docs/HANDBOOK.md Operational Notes if it exists

## COMPLETION

When the system works correctly — not when all original boxes are checked:
- All ACTIVE requirements (original + discovered) pass three gates
- Removed/amended REQs are documented in Spec Amendments with rationale
- Concerns section is empty or acknowledged by user
- Build + lint clean
- TODO.md reflects the final state of what was actually built
- Spec file updated to match reality (not the other way around)

<promise>ALL_REQUIREMENTS_VERIFIED</promise>
If blocked: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
  "$(cat /tmp/ralph-execute-prompt.txt)"
```

## Anti-Circumvention Notice

```!
echo "═══════════════════════════════════════════════════════════════════"
echo "Promise: ALL_REQUIREMENTS_VERIFIED"
echo ""
echo "Only output promise when:"
echo "  ✓ The system ACTUALLY WORKS — not just boxes checked"
echo "  ✓ All ACTIVE requirements (original + discovered) pass THREE gates"
echo "  ✓ Gate 3: Integration verification — run it, see it work"
echo "  ✓ Spec file updated to match what was actually built"
echo "  ✓ TODO.md Spec Amendments documented with rationale"
echo "  ✓ TODO.md Concerns section empty or user-acknowledged"
echo "  ✓ Build + lint clean (show actual output)"
echo "  ✓ CLAUDE.md updated with lessons learned"
echo ""
echo "Do NOT output promise just because you're stuck or tired."
echo "Do NOT skip Gate 3. Tests passing ≠ feature working."
echo "Do NOT grind through a bad spec. Amend it."
echo "═══════════════════════════════════════════════════════════════════"
```

---

## Completion

```
<promise>ALL_REQUIREMENTS_VERIFIED</promise>
```

If blocked:
```
<promise>BLOCKED: [reason]</promise>
```
