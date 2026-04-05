# TODO: {Plan Name}

## Plan
path: {$PLAN_PATH}
plan_id: {from plan frontmatter}

## Sessions
codex_session: {UUID}

## Build Environment (discovered or from plan)
test: {exact command}
lint: {exact command}
typecheck: {exact command}
build: {exact command}
start: {exact command}

## Test Integrity
test_snapshot: {sha256 hash of test files at start}

## Test Map
| Requirement | Source Files | Affected Tests | Backpressure | Review | Adversarial | Status |
|-------------|-------------|----------------|-------------|--------|-------------|--------|
| REQ-1       | src/auth.py | test_auth::login | tests ✓ lint ✓ types ✓ | Codex APPROVED r2 | Gemini PASS | DONE |
| REQ-2       | src/api.py  | test_api::create | tests ✗ (line 47) | pending | pending | IN PROGRESS |

## Roadmap
### REQ-1: {Name} [critical]
- [x] Adversarial tests written (RED) -- Codex, iter 1
- [x] Implementation (GREEN) -- Claude, iter 2
- [x] Backpressure: tests ✓ lint ✓ types ✓ build ✓ hash ✓
- [x] Integration: started server, hit /api/auth, got 200
- [x] Review: Codex APPROVED (round 2/5, HIGH confidence) -- iter 3
- [x] Adversarial: Gemini PASS (round 1/3, exhausted vectors) -- iter 3

### REQ-2: {Name} [critical]
- [x] Adversarial tests written (RED) -- Codex, iter 4
- [ ] Implementation -- Claude, iter 5 -- ACTIVE
- [ ] Backpressure
- [ ] Integration / Visual check
- [ ] Review: pending
- [ ] Adversarial: pending

## Decisions
- iter 2: chose {X} over {Y}
  - Codex: {agreed, noted risk Z}
  - Gemini: {preferred Y, but conceded on X given constraint}
  - Rationale: {why}

## Plan Amendments
- iter 3: REQ-3 approach changed -- {why, what changed}

## Concerns
- {things for user to review at completion}

## Walkthrough (written at completion)
- What was built and how it works
- Key decisions: {each with rationale}
- What diverged from the plan: {with why}
- What I'd improve in v2
- Remaining concerns for user review
