# Cross-Agent Review Taxonomy

DEFAULT VERDICT: **REJECT**. The code must prove it's correct.
False negatives (accepting bad code) are far more dangerous than false positives (rejecting good code).

## 5-Point Checklist

1. **SPECIFICATION FIDELITY**: Does the code implement the REQUIREMENT (WHEN/SHALL), not just pass the test? Compare against the acceptance criteria in the plan's Requirements table.

2. **HEURISTIC DETECTION**: Is this a general solution? Would it work on inputs NOT in the test suite? Or does it only handle the specific test cases? Look for: hardcoded values, conditional branches that match test inputs, lookup tables where algorithms should be.

3. **SOURCE FIDELITY**: Does the approach match the Source Map reference? If diverged, is the divergence justified and documented in TODO.md?

4. **EDGE CASES**: What input would break this? What's the blast radius of failure? Consider: empty/null, maximum values, unicode, concurrent access, malformed data.

5. **TEST ADEQUACY**: Do the tests cover the acceptance criteria, or just the happy path? Are there property-based invariants? Edge case coverage? Negative tests?

## Verdicts

- ANY check fails → **REJECT** with specific issue and fix suggestion
- ALL checks pass → **APPROVE** with confidence level:
  - **HIGH**: All checks pass cleanly, no concerns
  - **MEDIUM**: All checks pass but minor concerns exist → triggers another review round
  - **LOW**: Borderline pass, significant concerns → triggers another review round

## Iteration Rules

- Minimum 2 review rounds per requirement (never one-shot)
- Maximum 5 rounds (escalate to Concerns if not converging)
- Each round: fix issues from previous round → re-review
- Convergence: reviewer says APPROVE HIGH with no remaining issues
