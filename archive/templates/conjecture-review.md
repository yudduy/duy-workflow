# Conjecture Review

Single-conjecture quality gate. Test novelty, fundamentality, and accuracy using three specialized model roles dispatched in isolation.

**Use this when**: a conjecture has been formed (in /research, /discover, or elsewhere) and needs to be evaluated before promotion.

**Not a tournament**: this evaluates ONE conjecture, not two competing versions. For comparing versions, use autoreason-tournament.md.

---

## Setup

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
WS=/tmp/conjecture-review-$(openssl rand -hex 4)
mkdir -p "$WS"
echo "Conjecture review workspace: $WS"
```

## Inputs

The caller provides:
1. **CONJECTURE** — The specific falsifiable statement being evaluated. Written verbatim.
2. **LANDSCAPE SUMMARY** — What the field already knows (≤500 words from KNOWLEDGE-MAP.md or UNDERSTANDING.md).
3. **ASSUMPTION CHAIN** — The reasoning chain that led to this conjecture (≤200 words).
4. **CODEBASE CONTEXT** (optional) — Relevant code or implementation context for Codex to search.

Default verdict: **REJECT**. PROMOTE must be earned.

---

## Three-Role Dispatch (parallel, fully isolated)

All three dispatched simultaneously. None sees the others' output before producing their own.

### Role 1: Gemini — Abductive Probe (run_in_background: true, timeout: 300000)

Gemini's job: test novelty and implications. What does this conjecture imply? What would need to be true for it to hold? Is it genuinely novel?

```bash
gemini -m gemini-3.1-pro-preview -y -p \
  "CONJECTURE REVIEW — ABDUCTIVE PROBE.
  
  Conjecture: {CONJECTURE}
  
  Landscape (what the field already knows):
  {LANDSCAPE_SUMMARY}
  
  Assumption chain:
  {ASSUMPTION_CHAIN}
  
  Your job (abductive reasoning):
  1. NOVELTY: Is this conjecture genuinely novel? Search your knowledge for prior work that states or implies this.
     Name any papers, systems, or researchers that have expressed similar ideas.
     Be specific: 'X is novel' vs 'X was stated in [paper] as [quote]'.
  2. IMPLICATIONS: What does this conjecture imply? If true, what else must be true?
     What downstream conclusions follow? What would it break if false?
  3. WHAT WOULD NEED TO BE TRUE: List the 3-5 assumptions that must hold for this conjecture to be valid.
     Which is the weakest assumption? Which is hardest to verify?
  4. ABDUCTIVE VERDICT: Does this conjecture represent the SIMPLEST explanation that makes the observations unsurprising?
     Or is there a simpler explanation that achieves the same?
  
  Final verdict on a single line:
  ABDUCTIVE_VERDICT: [NOVEL|DERIVATIVE|UNCLEAR] — [one-line reason]" \
  > "$WS/probe-gemini.txt" 2>&1
```

### Role 2: Codex — Adversarial Inspector (run_in_background: true, timeout: 300000)

Codex's job: find this conjecture in literature or code, and attack it. It has codebase access — use it.

```bash
codex exec -m gpt-5.4 --full-auto --skip-git-repo-check \
  "CONJECTURE REVIEW — ADVERSARIAL INSPECTION.
  
  Conjecture: {CONJECTURE}
  
  Landscape (what the field already knows):
  {LANDSCAPE_SUMMARY}
  
  Codebase context (search this for contradicting implementations):
  {CODEBASE_CONTEXT}
  
  Your job (adversarial inspection):
  1. LITERATURE SEARCH: Search your knowledge and the codebase for prior work that:
     a. States this conjecture explicitly
     b. Implies this conjecture as a corollary
     c. Contradicts this conjecture with empirical evidence
     d. Tried this approach and found it failed
     Name specific papers, commits, functions, or systems with evidence.
  2. ADVERSARIAL ATTACK: Find the STRONGEST counterexample or contradicting evidence.
     What is the best argument AGAINST this conjecture?
     What assumption, if false, kills the conjecture entirely?
  3. FALSIFYING EVIDENCE: Is there any concrete evidence that falsifies this conjecture?
     Code that disproves it? An experiment result? A theorem that contradicts it?
  
  Final verdict on a single line:
  ADVERSARIAL_VERDICT: [KILL (falsifying evidence found)|ATTACK_STRONG|ATTACK_WEAK|NO_ATTACK] — [one-line reason with citation]" \
  > "$WS/probe-codex.txt" 2>&1
```

### Role 3: Claude Subagent — Synthesis (via Agent tool)

Claude's job: given the abductive probe AND the adversarial attack, determine if the conjecture is fundamental and accurate. This role sees both other outputs — it synthesizes, not produces independently.

**Wait for Gemini and Codex to complete before dispatching Claude.**

```
CONJECTURE REVIEW — SYNTHESIS.

Conjecture: {CONJECTURE}

Landscape: {LANDSCAPE_SUMMARY}
Assumption chain: {ASSUMPTION_CHAIN}

Abductive probe (Gemini's analysis):
{content of $WS/probe-gemini.txt}

Adversarial inspection (Codex's analysis):
{content of $WS/probe-codex.txt}

Your job: final synthesis verdict.
1. FUNDAMENTALITY: Is this conjecture load-bearing? Can you negate it without breaking the explanation?
   If negating the conjecture leaves the observations equally explained → it's not fundamental (decorative).
   If negating it requires a completely different model → it IS fundamental.
2. ACCURACY: Given the adversarial attack, does the conjecture still hold?
   Address the strongest attack specifically. Does it survive? Does it need revision?
3. CITATION REQUIREMENT: Every claim in your verdict must cite a source (paper, code, experiment result, logical argument).
   "Looks right" is not evidence.
4. SYNTHESIS: Given novelty (from Gemini) and adversarial attack (from Codex), what is the honest verdict?

Write to {WS}/synthesis-claude.txt.
Final verdict on a single line:
SYNTHESIS_VERDICT: [PROMOTE|REVISE|KILL] — [one-line reason]
```

---

## Verdict Tally

```bash
python3 << 'PYEOF'
import re, os

WS = os.environ.get('WS', '/tmp/conjecture-review')

def extract_verdict(path, pattern):
    if not os.path.exists(path): return "MISSING"
    text = open(path).read()
    m = re.search(pattern, text)
    return m.group(1) if m else "UNPARSED"

abductive = extract_verdict(f'{WS}/probe-gemini.txt',
    r'ABDUCTIVE_VERDICT:\s*([A-Z_]+)')
adversarial = extract_verdict(f'{WS}/probe-codex.txt',
    r'ADVERSARIAL_VERDICT:\s*([A-Z_]+)')
synthesis = extract_verdict(f'{WS}/synthesis-claude.txt',
    r'SYNTHESIS_VERDICT:\s*([A-Z_]+)')

print(f"Abductive (Gemini):    {abductive}")
print(f"Adversarial (Codex):   {adversarial}")
print(f"Synthesis (Claude):    {synthesis}")

# Determine final verdict
if 'KILL' in adversarial:
    final = 'KILL'
    reason = 'Codex found falsifying evidence'
elif synthesis == 'KILL':
    final = 'KILL'
    reason = 'Synthesis: conjecture does not survive adversarial pressure'
elif synthesis == 'PROMOTE' and 'KILL' not in abductive and 'KILL' not in adversarial:
    if abductive == 'NOVEL':
        final = 'PROMOTE'
        reason = 'Novel + survived attack + synthesis confirms fundamental'
    else:
        final = 'REVISE'
        reason = 'Synthesis approves but novelty unclear — verify prior art'
elif synthesis == 'REVISE' or 'ATTACK_STRONG' in adversarial:
    final = 'REVISE'
    reason = 'Strong attack survived or synthesis requires revision'
else:
    final = 'REJECT'  # Default
    reason = 'Insufficient evidence for promotion'

print(f"\nFINAL VERDICT: {final}")
print(f"Reason: {reason}")
PYEOF
```

---

## Outcomes

### PROMOTE
All three roles agree: novel, accurate, fundamental, no falsifying evidence.
→ Advance conjecture to UNDERSTANDING.md as active hypothesis.
→ Log as CANDIDATE in research loop.

### REVISE (with specific critique)
Conjecture has merit but needs refinement. Codex found related work that constrains scope, or attack revealed a beatable weakness.
→ The critique from whichever role triggered REVISE is the required fix.
→ Log revised conjecture + what changed in UNDERSTANDING.md.
→ Re-run conjecture-review after revision.

### KILL (with falsifying evidence)
Codex found concrete contradicting evidence (existing paper, code, experiment result) that disproves the conjecture, OR synthesis concludes the conjecture cannot survive the adversarial pressure.
→ Move conjecture to dead-ends with citation.
→ Dead ends are findings — log why it died.

**Default verdict: REJECT** (when evidence is insufficient for PROMOTE or KILL is not warranted — treat as REVISE with "needs more evidence").

---

## Log Format

Append to TODO.md (or UNDERSTANDING.md dead-ends section):
```
### Conjecture Review — {date}
- Conjecture: {one-line statement}
- Abductive: {NOVEL|DERIVATIVE|UNCLEAR} — {reason}
- Adversarial: {verdict} — {citation}
- Synthesis: {PROMOTE|REVISE|KILL} — {reason}
- Final: {PROMOTE|REVISE|KILL}
- Action: {what to do next — promote / what to revise / what evidence killed it}
```

---

## Role Summary

| Role | Model | What It Sees | Job |
|------|-------|-------------|-----|
| Abductive Probe | Gemini | Conjecture + Landscape + Assumption chain | Novelty, implications, what-would-need-to-be-true |
| Adversarial Inspector | Codex | Conjecture + Landscape + Codebase | Find in literature/code, strongest attack, falsifying evidence |
| Synthesizer | Claude subagent | Conjecture + BOTH prior roles' outputs | Fundamental? Accurate? Survive attack? Final verdict |

**Isolation**: Gemini and Codex dispatch in parallel with zero shared context. Claude synthesizes after both complete.
