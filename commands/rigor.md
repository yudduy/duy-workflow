---
description: "Apply Deletion · Presence · Urgency rigors to any task. First-principles audit that produces behavioral commitments, not essays. Trigger when researching, debugging, designing, planning, auditing, or when user says 'first principles', 'simplify', 'what's load-bearing', 'too complex', 'move faster'."
argument-hint: "<task or problem> [--audit-only] [--deep] [--system-scale]"
allowed-tools: Task, Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch, AskUserQuestion
---

# /rigor

Three operating rigors. Applied in order. Not a thinking exercise — a behavioral audit that produces concrete actions. Distilled from Jensen Huang's analysis of why Musk outpaces organizations.

## Flags

- `--audit-only`: Run the Three-Question Audit, output the assessment, stop. Don't execute.
- `--deep`: Full system-scale analysis (not just the component — the process, the approvals, the org structure around it).
- `--system-scale`: Alias for `--deep`.

## Phase 0: Scope the Target

Before applying rigors, identify what you're auditing:

```
1. WHAT is the task/problem/system? (one sentence)
2. WHAT LEVEL am I operating at? (component / architecture / process / organization)
3. WHAT WOULD SUCCESS LOOK LIKE in the minimum form?
```

Write this to a `rigor-audit.md` scratchpad (or stdout if `--audit-only`).

---

## Phase 1: DELETION

**Principle:** Default is subtraction, not addition. Every component, step, assumption, and dependency must justify its existence under interrogation. What cannot answer "I am load-bearing because _____" is a candidate for removal — not simplification, **removal**.

### Execute

**If the target is research / investigation:**
1. Strip the question to its bare physics. What is the minimum true thing we need to know to act?
2. List the top 5 implicit assumptions. Attack each: "What if this is false?"
3. For every source/variable/hypothesis considered: what does it *replace*, not *add*?

**If the target is code / system / architecture:**
1. For every abstraction layer, dependency, service, config value: "If this didn't exist, what breaks?"
   - If nothing breaks → mark for removal.
   - If the answer is vague → mark for removal.
2. For every step in the process (build step, approval, deployment stage): same test.
3. Identify what exists because of a past constraint that no longer holds.

**If the target is a plan / design / proposal:**
1. What is the smallest version that produces the needed result?
2. Which requirements exist because someone was afraid, not because they're needed?
3. If we started from physics today, would we build this same structure?

### Deletion Checklist

```
□ Smallest version identified
□ Past-constraint artifacts found and marked
□ First-principles reconstruction compared against current design
□ Inertia-driven components identified (kept because "we've always done it")
□ Removal vs. breakage verified for each candidate
```

### Failure Mode Detection

Flag yourself if you catch any of these:

| Symptom | Diagnosis |
|---|---|
| Cut visible things but hidden complexity grew | Bloat relocation |
| Removed things to appear minimal | Minimalism theater |
| Deleted without load-bearing analysis | Reckless subtraction |
| Simplified the interface, kept full system behind it | Cosmetic compression |
| Applied Deletion to components but not to the process itself | Local optimization |

**Litmus:** After deletion, does the system do the same thing with genuinely fewer moving parts — or did you just move the weight somewhere less visible?

---

## Phase 2: PRESENCE

**Principle:** Decision-making authority must stand over the actual problem. Not summaries. Not reports. Not interpretations. Proximity to the raw failure — no leaving until understood.

### Execute

**If the target is research / investigation:**
1. Go to primary sources. Read the paper, not the blog post. Read the data, not the summary table.
2. Reproduce the key finding before trusting it. A result you haven't independently touched is a rumor.
3. When confused, go to where the confusion lives — re-read, re-run, don't theorize from a distance.

**If the target is a bug / failure / incident:**
1. Read the actual error. The raw log, stack trace, failing test — in full. Not the ticket. Not someone's interpretation.
2. Reproduce it yourself before diagnosing. Can't reproduce → don't understand.
3. Instrument at the boundary where the behavior emerges. Don't form theories far from the failure.

**If the target is code / architecture:**
1. Read the actual implementation. Not the docs about the implementation. `Read` the file. `Grep` the function. Trace the call path.
2. If behavior is claimed ("X doesn't support Y"), test it. Don't trust the claim.
3. DeepWiki against source code, not against documentation.

### Presence Checklist

```
□ Working from primary sources, not summaries of summaries
□ Seen/run/reproduced the actual thing (not theorizing)
□ Identified and removed filters between me and raw truth
□ Can explain the mechanism without notes
```

### Failure Mode Detection

| Symptom | Diagnosis |
|---|---|
| Read a summary of the source instead of the source | Mediated understanding |
| In the codebase but haven't reproduced the failure | Tourism |
| Wrote more tests without understanding the failing one | Coverage without comprehension |
| Watched a demo instead of touching it directly | Spectator debugging |

**Litmus:** Can I explain — without notes — exactly how this works or fails, at the mechanical level? If not, I wasn't present enough. Go back.

---

## Phase 3: URGENCY

**Principle:** Urgency is demonstrated through the speed of your own motion, not declared through pressure on others. Compress the cycle time between problem and resolution.

### Execute

1. Identify the fastest path to a useful result — not a complete one.
2. What's the next action that gets closer to truth? Take it now. Don't queue it.
3. Ship the smallest thing that tests the hypothesis. Don't gold-plate before knowing it's the right direction.
4. When blocked: go to the source directly. Don't schedule a meeting about the block.
5. Measure: how long from "question arises" to "first real answer"? Compress it.

### Urgency Checklist

```
□ Fastest path to useful result identified (not complete result)
□ Next action is immediate, not queued
□ No gold-plating before direction is confirmed
□ Blocks are bypassed by going direct, not waiting in queue
□ First useful output ships before the plan is polished
```

### Failure Mode Detection

| Symptom | Diagnosis |
|---|---|
| Sending messages about the problem without moving | Communication velocity ≠ movement |
| Creating urgency in others via pressure | Manufactured urgency — compresses morale, not cycle time |
| Moving fast on the wrong thing | Speed misalignment |
| Working long hours on low-leverage tasks | Effort theater |
| Declaring priority without changing own behavior | Urgency signaling |

**Litmus:** Am I moving faster than the system's default pace because *I* am moving — or because I've told others to?

---

## Output

### If `--audit-only`:

Write to stdout:

```
RIGOR AUDIT: {task}
Level: {component / architecture / process / system}

DELETION:
- Minimum viable form: {description}
- Candidates for removal: {list with load-bearing analysis}
- Past-constraint artifacts: {list}
- Inertia items: {list}

PRESENCE:
- Primary source status: {what I touched directly vs. what I only read about}
- Reproduction status: {reproduced / not yet / not applicable}
- Remaining filters: {what's still between me and the raw truth}

URGENCY:
- Fastest useful result: {what and how}
- Next immediate action: {what, taking it now}
- Estimated cycle time: {question → first useful answer}

COMPLIANCE THEATER CHECK:
- What did I remove? {answer}
- What did I touch directly? {answer}
- How fast did I move? {answer}
- If any answer is "nothing" / "a report about it" / "still planning" → NOT APPLYING RIGORS

BEHAVIORAL COMMITMENTS:
1. {concrete action, not a thought}
2. {concrete action}
3. {concrete action}
```

### If executing (no `--audit-only`):

1. Run the audit silently.
2. Execute the behavioral commitments immediately.
3. Apply the rigors throughout the work — not once at the start.
4. At completion, append a 3-line rigor self-check:
   - Deleted: {what was removed}
   - Touched directly: {what was reproduced/verified hands-on}
   - Cycle time: {problem → resolution}

---

## System-Scale Application (`--deep`)

When `--deep` is set, apply all three rigors at every abstraction level simultaneously:

```
Component level  → the code, the function, the module
Architecture level → the system design, the service boundaries
Process level    → the workflow, the approval chain, the documentation ritual
Organization level → the team structure, the incentive structure
```

Musk applies Deletion to rockets AND to how rockets are built AND to who approves changes AND to how requirements are formed. The power is in applying all three rigors at every level, not just the one in front of you.

For each level, run the full three-phase audit. Output as nested sections.

---

## Anti-Pattern: Compliance Theater

The most common failure mode is performing the vocabulary without the behavior change:

- Talking about first principles instead of deriving from them
- Saying "let's simplify" while adding a simplification layer
- Claiming presence while reading summaries
- Declaring urgency while scheduling a meeting about it

**The check is always behavioral:** What did you remove? What did you touch directly? How fast did you move?

If the answers are "nothing," "a report about it," and "I'm still planning" — you are naming the rigors, not applying them.

---

## Quality Gates

Before completing:
- [ ] At least one thing was actually removed or marked for removal (Deletion)
- [ ] At least one primary source was read directly, not via summary (Presence)
- [ ] First useful action was taken within the first 10 minutes of invoking this skill (Urgency)
- [ ] No compliance theater detected in own output
- [ ] Behavioral commitments are concrete actions, not intentions
- [ ] Self-check answers are non-empty and honest
