# Autoreason Tournament

Universal quality gate. Empirical convergence through role isolation and blind evaluation.

**The problem with 3 models agreeing**: they can all be wrong in the same direction if they share context. "All agree" is not evidence — it's correlated noise.

**The tournament solution**: isolated roles, blind labels, empirical convergence. An incumbent wins when 3 independent judges, seeing only opaque labels, consistently pick it under fresh adversarial pressure. That's structural honesty.

---

## When to Use

Call this template instead of deliberation-protocol.md's 3-round debate when:
- The decision is hard to reverse
- Sycophancy risk is high (models have seen each other's outputs, or the answer seems "obvious")
- The stakes are major (architecture, design, research conclusion, conjecture verdict)
- You want empirical convergence, not agreement convergence

## When NOT to Use

- Mechanical/reversible choices the plan already decided — just execute
- Routine multi-model checks where a single parallel round suffices (use deliberation-protocol.md quick dispatch)
- When you only have one version and just want critique (use adversarial-prompt.md)

---

## Setup

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
WS=/tmp/tournament-$(openssl rand -hex 4)
mkdir -p "$WS"
INCUMBENT="$WS/incumbent.txt"
CHALLENGER="$WS/challenger.txt"
SYNTHESIZED="$WS/synthesized.txt"
LOG="$WS/tournament-log.md"
CONSECUTIVE_WINS=0
ROUND=0
echo "Tournament workspace: $WS" | tee "$LOG"
```

## Inputs

The caller provides before entering the loop:
1. **QUESTION** — The decision being evaluated. One sentence.
2. **CONTEXT** — Relevant constraints, plan excerpt, domain context (≤500 words).
3. **Version A** (initial incumbent) — Current position, design, or implementation. Written to `$INCUMBENT`.
4. **Version B** (initial challenger, optional) — Alternative version. If not provided, the tournament auto-generates challengers via adversarial pressure in each round.

```bash
# Write initial versions
echo "{version_A_content}" > "$INCUMBENT"
echo "{version_B_content_or_empty}" > "$CHALLENGER"
```

---

## The Loop

Run rounds until `CONSECUTIVE_WINS >= 3` or `ROUND >= 10`.

```bash
while [ "$CONSECUTIVE_WINS" -lt 3 ] && [ "$ROUND" -lt 10 ]; do
  ROUND=$((ROUND + 1))
  echo "=== ROUND $ROUND (consecutive wins: $CONSECUTIVE_WINS/3) ===" | tee -a "$LOG"
  # Steps 1-5 below
done
```

### Step 1: ATTACK (parallel, isolated)

Each adversary sees ONLY the question + context + ONE version. Full isolation — no cross-contamination.

**Codex attacks incumbent** (run_in_background: true, timeout: 300000):
```bash
codex exec -m gpt-5.4 --full-auto --skip-git-repo-check \
  "ADVERSARIAL ATTACK — Round $ROUND.
  Question: {QUESTION}
  Context: {CONTEXT}
  
  Target version:
  $(cat $INCUMBENT)
  
  Your only job: find fatal flaws. Search the codebase and literature.
  Find: logical contradictions, edge cases missed, factual errors, weakest assumptions,
  counterexamples, simpler alternatives that make this unnecessary.
  BE RUTHLESS. Default verdict is REJECT. Approval must be earned.
  Write full attack to $WS/attack-incumbent-r${ROUND}.txt
  Last line: ATTACK_STRENGTH: [WEAK|MODERATE|STRONG|FATAL]" 2>&1
```

**Gemini attacks challenger** (run_in_background: true, timeout: 300000):
```bash
gemini -m gemini-3.1-pro-preview -y -p \
  "ADVERSARIAL ATTACK — Round $ROUND.
  Question: {QUESTION}
  Context: {CONTEXT}
  
  Target version:
  $(cat $CHALLENGER)
  
  Your only job: find fatal flaws.
  Find: logical contradictions, missing assumptions, counterexamples, failure modes,
  where this breaks under adversarial pressure. What would a ruthless peer reviewer say?
  BE RUTHLESS. Default verdict is REJECT.
  Last line: ATTACK_STRENGTH: [WEAK|MODERATE|STRONG|FATAL]" \
  > "$WS/attack-challenger-r${ROUND}.txt" 2>&1
```

Wait for both attacks to complete.

### Step 2: SYNTHESIZE (isolated, Claude subagent)

Synthesizer sees: both versions + both attacks. Does NOT know which attack targeted which version.
Synthesizer's job: produce AB — the best combination of A and B that addresses both attacks.

**Claude subagent** (via Agent tool):
```
SYNTHESIS TASK — Round {ROUND}.
Question: {QUESTION}
Context: {CONTEXT}

Version A:
{content of $INCUMBENT}

Version B:
{content of $CHALLENGER}

Adversarial Attack 1 (not labeled by target):
{content of $WS/attack-incumbent-r{ROUND}.txt}

Adversarial Attack 2 (not labeled by target):
{content of $WS/attack-challenger-r{ROUND}.txt}

Create Version AB: the strongest synthesis of A and B that addresses both attacks.
- If A is already optimal, AB may be nearly identical to A with minor hardening.
- If B has important strengths A lacks, incorporate them.
- AB must be concretely defensible against both attacks.

Write ONLY the synthesized version to {WS}/synthesized-r{ROUND}.txt (no preamble).
Last line: SYNTHESIS_CONFIDENCE: [0-100]
```

### Step 3: JUDGE PANEL (parallel, isolated, randomized labels)

**⚠ Randomization is load-bearing.** Labels must be shuffled, not ordinal. This prevents positional bias (first-listed wins more often).

```bash
python3 << 'PYEOF'
import random, json, sys, os

WS = os.environ.get('WS', '/tmp/tournament')
ROUND = os.environ.get('ROUND', '1')

incumbent = open(f'{WS}/incumbent.txt').read()
challenger = open(f'{WS}/challenger.txt').read()
synthesized_path = f'{WS}/synthesized-r{ROUND}.txt'
synthesized = open(synthesized_path).read() if os.path.exists(synthesized_path) else incumbent

versions = {'incumbent': incumbent, 'challenger': challenger, 'synthesized': synthesized}
greek = ['α', 'β', 'γ']
keys = list(versions.keys())
random.shuffle(keys)  # TRUE shuffle — not sorted, not ordered by input

mapping = {greek[i]: keys[i] for i in range(3)}
labeled_content = {greek[i]: versions[keys[i]] for i in range(3)}

with open(f'{WS}/label-mapping-r{ROUND}.json', 'w') as f:
    json.dump({'mapping': mapping, 'round': ROUND}, f, indent=2)

# Write judge prompt context
for label in greek:
    with open(f'{WS}/judge-content-{label}-r{ROUND}.txt', 'w') as f:
        f.write(labeled_content[label])

print(f"Labels randomized: {mapping}")
PYEOF
```

Each judge receives ONLY: question + context + 3 opaquely-labeled versions. They do NOT see:
- Attack outputs
- Synthesis rationale
- Which label corresponds to which version
- Each other's votes

**Codex judge** (run_in_background: true, timeout: 300000, FRESH context):
```bash
codex exec -m gpt-5.4 --full-auto --skip-git-repo-check \
  "JUDGE — Round $ROUND. Pick the best version. You have no other information.
  Question: {QUESTION}
  Context: {CONTEXT}
  
  Version α:
  $(cat $WS/judge-content-α-r${ROUND}.txt)
  
  Version β:
  $(cat $WS/judge-content-β-r${ROUND}.txt)
  
  Version γ:
  $(cat $WS/judge-content-γ-r${ROUND}.txt)
  
  Which version best answers the question? Judge independently. Do not defer.
  Explain your reasoning. Last line: VERDICT: [α|β|γ]" \
  2>&1 | tee "$WS/judge-codex-r${ROUND}.txt"
```

**Gemini judge** (run_in_background: true, timeout: 300000, FRESH context):
```bash
gemini -m gemini-3.1-pro-preview -y -p \
  "JUDGE — Round $ROUND. Pick the best version. You have no other information.
  Question: {QUESTION}
  Context: {CONTEXT}
  
  Version α:
  $(cat $WS/judge-content-α-r${ROUND}.txt)
  
  Version β:
  $(cat $WS/judge-content-β-r${ROUND}.txt)
  
  Version γ:
  $(cat $WS/judge-content-γ-r${ROUND}.txt)
  
  Which version best answers the question? Judge independently.
  Last line: VERDICT: [α|β|γ]" \
  > "$WS/judge-gemini-r${ROUND}.txt" 2>&1
```

**Claude judge** (via Agent tool, FRESH context):
```
JUDGE — Round {ROUND}. Pick the best version. You have no other information.
Question: {QUESTION}
Context: {CONTEXT}

Version α:
{content of $WS/judge-content-α-r{ROUND}.txt}

Version β:
{content of $WS/judge-content-β-r{ROUND}.txt}

Version γ:
{content of $WS/judge-content-γ-r{ROUND}.txt}

Which version best answers the question? Reason from first principles. Do not defer.
Write your reasoning and last line: VERDICT: [α|β|γ]
Write to {WS}/judge-claude-r{ROUND}.txt
```

Wait for all 3 judges.

### Step 4: TALLY + UPDATE INCUMBENT

```bash
python3 << 'PYEOF'
import re, json, os, sys

WS = os.environ.get('WS', '/tmp/tournament')
ROUND = os.environ.get('ROUND', '1')

mapping = json.load(open(f'{WS}/label-mapping-r{ROUND}.json'))['mapping']

def extract_verdict(path):
    if not os.path.exists(path): return None
    text = open(path).read()
    m = re.search(r'VERDICT:\s*([αβγ])', text)
    return m.group(1) if m else None

verdicts = {
    'codex':  extract_verdict(f'{WS}/judge-codex-r{ROUND}.txt'),
    'gemini': extract_verdict(f'{WS}/judge-gemini-r{ROUND}.txt'),
    'claude': extract_verdict(f'{WS}/judge-claude-r{ROUND}.txt'),
}
print(f"Verdicts: {verdicts}")

non_null = [v for v in verdicts.values() if v]
if len(non_null) == 3 and len(set(non_null)) == 1:
    winner_label = non_null[0]
    winner_version = mapping[winner_label]
    print(f"UNANIMOUS: {winner_label} = {winner_version}")
    
    # Write winner as new incumbent
    winner_content = open(f'{WS}/judge-content-{winner_label}-r{ROUND}.txt').read()
    open(f'{WS}/incumbent.txt', 'w').write(winner_content)
    open(f'{WS}/round-{ROUND}-result.txt', 'w').write(f"WINNER: {winner_version}\nVERDICT: UNANIMOUS")
else:
    print(f"SPLIT: {verdicts} — no consensus, incumbent unchanged")
    open(f'{WS}/round-{ROUND}-result.txt', 'w').write(f"WINNER: SPLIT\nVERDICT: NO_CONSENSUS")
PYEOF
```

After tally:
- **If unanimous and winner = incumbent**: `CONSECUTIVE_WINS=$((CONSECUTIVE_WINS + 1))`
- **If unanimous and winner ≠ incumbent**: `CONSECUTIVE_WINS=1` (new incumbent, reset streak)
- **If split**: `CONSECUTIVE_WINS` unchanged. New challenger = author₂ generates a fresh alternative. Retry this round (max 1 retry per round).

For the next round, the challenger is generated by Gemini responding to the incumbent + the attack from this round:
```bash
gemini -m gemini-3.1-pro-preview -y -p \
  "CHALLENGER GENERATION.
  Question: {QUESTION}
  Context: {CONTEXT}
  Current incumbent: $(cat $WS/incumbent.txt)
  Adversarial attack on incumbent: $(cat $WS/attack-incumbent-r${ROUND}.txt)
  
  Propose a BETTER version that addresses the attack while preserving what's strong.
  Don't just patch — improve. If the attack reveals a fundamental flaw, redesign.
  Write ONLY the revised version." \
  > "$WS/challenger.txt" 2>&1
```

### Step 5: LOG THE ROUND

```bash
ROUND_RESULT=$(cat "$WS/round-${ROUND}-result.txt")
cat >> "$LOG" << LOGEOF

## Round ${ROUND}
- Incumbent: $(head -1 $WS/incumbent.txt | cut -c1-80)...
- Challenger: $(head -1 $WS/challenger.txt | cut -c1-80)...
- Attack (incumbent) strength: $(grep 'ATTACK_STRENGTH' $WS/attack-incumbent-r${ROUND}.txt | tail -1)
- Attack (challenger) strength: $(grep 'ATTACK_STRENGTH' $WS/attack-challenger-r${ROUND}.txt | tail -1)
- Synthesis confidence: $(grep 'SYNTHESIS_CONFIDENCE' $WS/synthesized-r${ROUND}.txt | tail -1)
- Codex verdict: $(grep 'VERDICT' $WS/judge-codex-r${ROUND}.txt | tail -1)
- Gemini verdict: $(grep 'VERDICT' $WS/judge-gemini-r${ROUND}.txt | tail -1)
- Claude verdict: $(grep 'VERDICT' $WS/judge-claude-r${ROUND}.txt | tail -1)
- Label mapping: $(cat $WS/label-mapping-r${ROUND}.json | python3 -c "import json,sys; m=json.load(sys.stdin)['mapping']; print(', '.join(f'{k}={v}' for k,v in m.items()))")
- Round winner: $ROUND_RESULT
- Consecutive wins: ${CONSECUTIVE_WINS}/3
LOGEOF
```

---

## Convergence

**DONE**: `CONSECUTIVE_WINS >= 3`

```bash
if [ "$CONSECUTIVE_WINS" -ge 3 ]; then
  echo "TOURNAMENT CONVERGENT: incumbent won $CONSECUTIVE_WINS consecutive rounds" | tee -a "$LOG"
  echo "Winner: $(cat $WS/incumbent.txt)"
  echo "Rounds run: $ROUND"
  echo "Log: $LOG"
fi
```

**INCONCLUSIVE**: `ROUND >= 10` without convergence → return current incumbent with flag.

```bash
if [ "$ROUND" -ge 10 ] && [ "$CONSECUTIVE_WINS" -lt 3 ]; then
  echo "TOURNAMENT INCONCLUSIVE: no convergence after 10 rounds" | tee -a "$LOG"
  echo "Returning current incumbent. Apply Decision Precedence from plan."
fi
```

---

## Output

Log to TODO.md Decisions section:
```
- iter N: Tournament — {QUESTION}
  - Winner: {one-line description of winning version}
  - Rounds: {N} | Status: CONVERGENT (3 consecutive wins) | INCONCLUSIVE
  - Judge agreement: unanimous in rounds {list}
  - Key reason: {summary of why judges preferred winner}
  - Log: {WS}/tournament-log.md
```

---

## Role Summary

| Role | Model | Context | What It Sees |
|------|-------|---------|-------------|
| Adversary (incumbent) | Codex | FRESH | Question + Context + Incumbent only |
| Adversary (challenger) | Gemini | FRESH | Question + Context + Challenger only |
| Synthesizer | Claude subagent | FRESH | Both versions + both attacks (unlabeled) |
| Judge 1 | Codex | FRESH | Question + Context + 3 randomized labeled versions |
| Judge 2 | Gemini | FRESH | Question + Context + 3 randomized labeled versions |
| Judge 3 | Claude subagent | FRESH | Question + Context + 3 randomized labeled versions |

**Critical**: No model in any role may see another model's output before their own production phase. Role isolation is enforced by prompt discipline — each agent receives ONLY what's in the "What It Sees" column.

---

## Why This Works

1. **Isolation prevents anchor drift**: adversary has no sycophantic surface to grab — it attacks blindly
2. **Blind labels remove authorship bias**: judges can't defer to "the model that proposed this" because they don't know who proposed what
3. **Empirical convergence > agreement convergence**: 3 consecutive unanimous rounds means the winner is consistently better across different adversarial pressures, not just once
4. **Odd panel size prevents ties**: 3 judges never deadlock
5. **Different model families for judges**: Codex, Gemini, Claude represent genuinely different training distributions — unanimous verdict across all 3 is meaningful evidence
