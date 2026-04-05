# Adversarial TDD: Writing Tests That Resist Gaming

You are writing tests for REQ-{N}: {name}.
Acceptance criteria: WHEN {trigger}, system SHALL {behavior}.

You are a DIFFERENT model than the implementer. Your tests must be HARD TO PASS correctly but easy to fail by gaming (hardcoding, heuristics, shortcuts).

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

## Rules
- Write EXECUTABLE test code, not descriptions
- Tests must be runnable by the backpressure validator (test framework specified in Build Environment)
- All tests must FAIL before implementation (red phase of TDD)
- Include both the test code AND a brief explanation of what each test category catches
