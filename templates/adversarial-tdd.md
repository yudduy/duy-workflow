# Adversarial TDD: Writing Tests That Resist Gaming

You are writing tests for REQ-{N}: {name}.
Acceptance criteria: WHEN {trigger}, system SHALL {behavior}.

You are a DIFFERENT model than the implementer. Your tests must be HARD TO PASS correctly but easy to fail by gaming (hardcoding, heuristics, shortcuts).

## Refactor mode (behavior-preserving)
If this is a refactor, not a new feature, there is no new behavior to specify — the current behavior IS the spec. Before any edit, state the triad:
**current behavior** (must not change) → **structural change** (delete dead path / extract helper / modernize pattern) → **proof** (a Category 6 parity test).
Capture the golden output FIRST, while the old code still runs. Then refactor until parity holds.

## Test Categories (write tests in ALL categories that apply)

### 1. Acceptance Criteria (WHEN/SHALL)
Direct tests of the stated requirement. Both positive AND negative paths.
- WHEN valid input → system SHALL produce correct output
- WHEN invalid input → system SHALL reject with specific error

### 2. Property-Based Invariants
NOT specific I/O pairs like `assert f(2,3) == 5`.
Instead: relationships that MUST hold for ALL valid inputs.

Examples:
- Commutativity: `f(a, b) == f(b, a)`
- Idempotency: `f(f(x)) == f(x)`
- Round-trip: `decode(encode(x)) == x`
- Monotonicity: `a <= b → f(a) <= f(b)`
- Conservation: `len(output) == len(input)` (if applicable)
- Ordering: `sorted(f(x)) == f(sorted(x))` (if applicable)

These catch heuristic solutions that only handle known test cases.

### 3. Edge Case Gauntlet
- Empty/null/undefined inputs
- Maximum/minimum values (INT_MAX, empty string, zero-length array)
- Overflow, underflow, exactly-at-boundary (off-by-one territory)
- Unicode, special characters, injection attempts (SQL, XSS, path traversal)
- Single element, duplicate elements, already-sorted, reverse-sorted
- Very large inputs (performance/resource exhaustion)

### 4. Negative Tests
- Invalid inputs → must reject with SPECIFIC error (not crash, not silent swallow)
- Unauthorized access → must deny
- Malformed data → must handle gracefully
- Out-of-range parameters → must validate and report

### 5. Mutation-Killing Tests
"If you change {specific aspect of correct implementation}, this test MUST fail."
Tests that are sensitive to the CORRECTNESS of the implementation, not just its output format.

### 6. Characterization / Parity Tests (behavior-preserving refactors only)
The test is the OLD behavior, not a spec. Use when output MUST NOT change.
- Capture current output as a golden snapshot BEFORE touching code (record it, don't hand-write it).
- Assert `refactored(x) == legacy(x)` across real AND fuzzed inputs — diff the two side by side.
- Pin observable side effects too: emitted events, DB writes, call order, log/error messages.
These catch silent drift that property tests miss: a refactor can preserve every invariant and still change output.

## Rules
- Write EXECUTABLE test code, not descriptions
- Tests must be runnable by the backpressure validator (test framework specified in Build Environment)
- All tests must FAIL before implementation (red phase of TDD)
- Include both the test code AND a brief explanation of what each test category catches
