---
description: Deploy agents to verify PoC logic and recommend improvements from frontier research
argument-hint: "[path/to/poc]"
impact: CRITICAL
when-to-use: Before running experiments - verifies correctness AND surfaces improvements
---

# /verify-poc

Deploy parallel agents to verify implementations and surface frontier research recommendations.

---

## Step 0: Quick Environment Check

Before technique verification, run a fast sanity check:

```
Task tool (Explore, quick): "Environment sanity check for [path]:

1. DEPENDENCIES: Is there a lockfile? (poetry.lock, package-lock.json, Cargo.lock, go.sum)
   - If no lockfile: WARN - not reproducible
   - If unpinned versions (>=, ~, ^, *): WARN - floating deps

2. CHECKPOINTS: Does code save intermediate state?
   - Search for: checkpoint, save_state, serialize, pickle, .json writes
   - If none found: WARN - no recovery on failure

3. DATA VALIDATION: Are there input assertions?
   - Search for: assert, raise ValueError, validate, check
   - If none on inputs: WARN - garbage in → garbage out

Return: [ALL OK] or [WARNINGS: list what's missing]"
```

---

## Step 1: Discover Techniques

```
Task tool (Explore): "Find all algorithm implementations in [path]. Look for:
- Paper references (arXiv, DOI)
- Algorithm names (PUCT, GRPO, PPO, SAC, etc.)
- Mathematical formulas in comments

Return: technique name, file:line, cited source."
```

---

## Step 2: Deploy Verification Agents (parallel)

**One agent per technique.** Each agent does:

```
Task tool (general-purpose): "Verify and improve [TECHNIQUE_NAME] at [file:line].

1. RESEARCH THE TECHNIQUE
   - WebSearch for original paper/documentation
   - Find canonical formula and parameters
   - Note common implementation mistakes

2. READ THE IMPLEMENTATION
   - Actual code, not just comments
   - Parameter values, edge case handling

3. VERIFY CORRECTNESS
   - Does formula match source?
   - Are parameters correct?
   - Edge cases handled?

   Report: MATCH | MISMATCH | DEVIATION (with details)

4. RESEARCH FRONTIER IMPROVEMENTS
   - WebSearch '[technique] improvements 2024 2025'
   - WebSearch '[technique] best practices'
   - WebSearch '[technique] common pitfalls'
   - Look for: newer variants, known issues, optimization tricks

5. GENERATE RECOMMENDATIONS
   Based on verification AND frontier research:
   - Critical fixes (implementation bugs)
   - Performance improvements (from recent papers)
   - Best practices (from community experience)
   - Alternative approaches (if technique is outdated)"
```

---

## Step 3: Collect Results

```markdown
## PoC Verification: [Name]

**Status:** VERIFIED | ISSUES FOUND

### Environment Check
- Dependencies: [pinned/unpinned/missing lockfile]
- Checkpoints: [found/not found]
- Data validation: [found/not found]

### [Technique 1]

**Verification:**
- Source: [paper/doc]
- Status: MATCH | MISMATCH | DEVIATION
- Details: [comparison]

**Frontier Research:**
- Latest variant: [if any newer version exists]
- Known issues: [from community]
- Performance tips: [from recent papers]

**Recommendations:**
| Priority | Type | Recommendation |
|----------|------|----------------|
| HIGH | Bug | [fix implementation error] |
| MEDIUM | Improvement | [apply recent optimization] |
| LOW | Best Practice | [style/pattern suggestion] |

### [Technique 2]
...

### Summary
- Environment warnings: [count]
- Critical issues: [count]
- Recommended improvements: [count]
- Implementation quality: [good/acceptable/needs work]

### Action Items
1. **[HIGH]** [most critical fix]
2. **[MEDIUM]** [important improvement]
3. **[LOW]** [nice to have]
```

---

## Example

**Input:** `/verify-poc poc/`

**Step 0 output:**
```
Environment Check:
- Dependencies: poetry.lock found, all pinned ✓
- Checkpoints: save_state() found in sampler.py:120 ✓
- Data validation: WARN - no input assertions on rewards
```

**Step 1 finds:**
```
1. PUCT Sampler (poc/sampler.py:45) - cites arXiv:2601.16175
2. Entropic Advantage (poc/entropic.py:12) - cites same paper
```

**Step 2 deploys 2 agents in parallel:**

Agent 1 (PUCT):
```markdown
### PUCT Sampler

**Verification:**
- Source: TTT-Discover (arXiv:2601.16175), AlphaGo Zero
- Status: MATCH (with documented deviations)
- c=1.5 vs paper c=1.0: documented
- group_size used correctly (unlike main codebase bug)

**Frontier Research:**
- MuZero (2020): Uses learned dynamics model, not applicable here
- EfficientZero (2021): Sample-efficient variant, could reduce iterations
- Recent (2024): Progressive widening for continuous action spaces
- Common pitfall: Using max(Q) instead of mean(Q) for backups
- Best practice: UCB1-tuned provides better regret bounds

**Recommendations:**
| Priority | Type | Recommendation |
|----------|------|----------------|
| MEDIUM | Improvement | Consider UCB1-tuned variant for tighter exploration |
| LOW | Best Practice | Add logging for PUCT score components for debugging |
| INFO | Alternative | EfficientZero's reanalyze could improve sample efficiency |
```

Agent 2 (Entropic Advantage):
```markdown
### Entropic Advantage

**Verification:**
- Source: TTT-Discover (arXiv:2601.16175), Section 3.3
- Status: DEVIATION
- β is fixed at 1.0, paper uses adaptive β targeting KL=ln(2)

**Frontier Research:**
- SAC (2018): Automatic entropy tuning via dual gradient descent
- REDQ (2021): Better sample efficiency with ensemble Q
- Recent (2024): GFlowNet objectives for diverse exploration
- Common pitfall: Fixed β leads to suboptimal exploration/exploitation
- Best practice: Adaptive β with KL constraint is standard now

**Recommendations:**
| Priority | Type | Recommendation |
|----------|------|----------------|
| HIGH | Bug | Implement adaptive β (paper shows ~20% improvement) |
| MEDIUM | Improvement | Use SAC-style dual optimization for β |
| LOW | Alternative | Consider GFlowNet objective for diversity |
```

**Final Report:**

```markdown
## PoC Verification: TTT-Discover PoC

**Status:** ISSUES FOUND

### Environment Check
- Dependencies: pinned ✓
- Checkpoints: found ✓
- Data validation: WARN - add reward assertions

### Summary
- Environment warnings: 1
- Critical issues: 1 (adaptive β missing)
- Recommended improvements: 3
- Implementation quality: Acceptable (fixes needed)

### Action Items
1. **[HIGH]** Implement adaptive β before experiments
2. **[HIGH]** Add input validation for rewards (env check)
3. **[MEDIUM]** Consider UCB1-tuned for PUCT
4. **[LOW]** Add PUCT component logging for debugging

### Frontier Techniques to Consider
- EfficientZero's reanalyze for sample efficiency
- SAC-style dual optimization for entropy
```

---

## Key Points

- **Step 0** catches "it works on my machine" failures in 30 seconds
- Each agent: **verifies** correctness AND **researches** improvements
- Recommendations include **priority** (HIGH/MEDIUM/LOW)
- Types: Bug, Improvement, Best Practice, Alternative
- Surfaces **frontier research** - not just "is it correct" but "is it optimal"
- Output is actionable with clear priorities
