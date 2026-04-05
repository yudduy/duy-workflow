# First-Principles Rigor: Deletion · Presence · Urgency

Three operating rigors. Apply in order during any research, engineering, or planning task.

## Rigor 1 — DELETION (Subtraction as the primary tool)

Default is subtraction, not addition. Every component, step, assumption, and dependency must justify its existence. What cannot answer "I am load-bearing because _____" gets removed — not simplified, **removed**.

**Deletion Audit:**
- What is the smallest version that produces the needed result?
- Which steps/parts exist because of a past constraint that no longer exists?
- If we started from first principles today, would we build this same structure?
- What is kept out of inertia, fear, or because no one had the nerve to cut it?
- Does removing X break something real, or just something we're used to?

**Failure modes (what Deletion is NOT):**
- Cutting visible things while hidden complexity grows (bloat relocation)
- Removing things to appear minimal (minimalism theater)
- Deleting without load-bearing analysis (reckless subtraction)
- Simplifying the interface while keeping the full system behind it (cosmetic compression)

**Litmus:** After deletion, does the system do the same thing with genuinely fewer moving parts — or did you just move the weight somewhere less visible?

## Rigor 2 — PRESENCE (Proximity to the actual failure)

Decision-making authority must stand over the actual problem. Not summaries. Not slides. Not filtered reports. Physical or cognitive proximity to the raw failure — and no leaving until it's understood.

**Presence Checklist:**
- Am I working from primary sources or summaries of summaries?
- Have I seen/run/reproduced the actual failure or am I theorizing?
- What is the closest I can get to the point where the problem actually lives?
- Whose filter is between me and the raw truth — and can I remove it?

**Failure modes (what Presence is NOT):**
- Reading a detailed summary of the primary source (mediated understanding)
- Being in the codebase without reproducing the failure (tourism)
- Writing more tests without first understanding the failing one (coverage without comprehension)

**Litmus:** Could you explain — without notes — exactly how the failure occurs, at the mechanical level? If not, you weren't present enough.

## Rigor 3 — URGENCY (Demonstrated speed as social/physical force)

Urgency is not declared. It is demonstrated through the speed of your own motion. Compress the cycle time between problem and resolution.

**Urgency Checklist:**
- What is the fastest path to a useful result — not a complete one?
- Am I queued behind something I could bypass by just going there?
- What's the cycle time between this problem arising and me having touched it?
- Am I waiting for permission or information that I could simply go get?

**Failure modes (what Urgency is NOT):**
- Sending rapid messages about a problem (communication velocity without movement velocity)
- Creating urgency in others through pressure (manufactured urgency)
- Moving fast on the wrong thing (speed misalignment)
- Working long hours on low-leverage tasks (effort theater)

**Litmus:** Are you moving faster than the system's default pace because *you* are moving, not because you've told others to?

## Three-Question Audit (run at the start of any non-trivial task)

```
1. DELETION: What is the minimum true question / minimal viable system here?
   → Kill every requirement, assumption, and step that can't survive interrogation.

2. PRESENCE: What is the closest I can get to the actual problem right now?
   → Identify what filters stand between me and the raw truth. Remove them.

3. URGENCY: What is the next action I can take in the next 10 minutes?
   → Don't plan the whole path. Take the first step fast enough to learn from it.
```

## System-Scale Note

These apply at every level simultaneously — not just the component, but the architecture, the process that produced it, the meeting that governs the process, and the organizational structure around the project. The power is in applying all three at every level of abstraction.

**Anti-pattern:** Compliance theater — performing the vocabulary without the behavior change. The check is always behavioral: What did you remove? What did you touch directly? How fast did you move?
