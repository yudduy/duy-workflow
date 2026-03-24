---
description: "Fully autonomous engineering loop with anti-reward-hacking scaffolding. Multi-model consultation at decisions. Process rewards via backpressure validators. Never asks the user."
argument-hint: "[--max-iterations N]"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, mcp__deepwiki__ask_question, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__get_page_text, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__tabs_context_mcp
---

# /execute

Fully autonomous. The user is away. Build the thing, verify it works, walk them through decisions when they return.

## Pre-flight (MANDATORY -- run before anything else)

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
PLAN=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)
if [ -z "$PLAN" ]; then
  echo "BLOCKED: No plan found in .claude/plans/"
  echo "Run /interview first to create a Product Intent Document."
  echo "The plan must be a file on disk -- Plan Mode context does not survive /clear."
  exit 1
fi
echo "Plan found: $PLAN"
cat "$PLAN"
```

If the pre-flight fails, do NOT proceed. Do NOT try to infer what to build from git history or README. Tell the user: "No plan found. Run /interview first."

## Autonomy Rules

- **NEVER AskUserQuestion** for technical decisions. Dispatch to Codex/Gemini instead.
- **Only stop for**: missing credentials, missing access, genuinely unresolvable without human knowledge.
- **Log every significant decision** in TODO.md with: what, why, alternatives, which models consulted, agreement level.
- **At completion**: write WALKTHROUGH in TODO.md -- the user reviews this when they return.
- **NEVER present unreviewed work.** The user's time is the most expensive resource. Every cross-agent review is ITERATIVE (review -> fix -> re-review -> converge), not one-shot. The Walkthrough must be reviewed by Codex/Gemini before the user sees it. You are the LAST quality gate before the user, not the first.

---

## Anti-Reward-Hacking Principles

These are structural, not advisory. You cannot bypass them.

### 1. Backpressure Validators (deterministic, per-commit)
Before ANY commit, ALL of these must pass. No exceptions. No skipping "just this once."

```bash
# The backpressure gate -- run BEFORE every commit
# Backend
TEST_EXIT=$(run_tests)        # All tests pass (not just new ones)
LINT_EXIT=$(run_linter)       # Zero warnings policy
TYPE_EXIT=$(run_type_check)   # Type checker clean (mypy/tsc)
BUILD_EXIT=$(run_build)       # Build succeeds

# Frontend (if applicable)
# Use Claude-in-Chrome MCP to visually verify UI changes
```

If ANY validator fails → fix it. Do not commit broken code and promise to fix later.

### 2. Test Map (TDAD pattern -- WHICH tests, not HOW to test)
For each requirement, identify the specific test files/functions that verify it. Don't write generic "test everything" -- map source files to their affected tests. This is the process reward signal.

```markdown
## Test Map (in TODO.md)
| Requirement | Source Files | Affected Tests | Status |
|-------------|-------------|----------------|--------|
| REQ-1       | src/auth.py | tests/test_auth.py::test_login, test_logout | PASS |
| REQ-2       | src/api.py  | tests/test_api.py::test_create, test_validate | FAIL |
```

### 3. Cross-Agent Review (independent verification)
No requirement is DONE until reviewed by a different agent. You cannot self-certify.
- You implement → Codex reviews (or vice versa)
- The reviewer checks against the acceptance criteria, not your description of what you did

### 4. Constraint Re-injection (every 5 iterations)
Long context causes goal drift. Every 5 iterations:
1. Re-read the plan from `.claude/plans/`
2. Re-read CLAUDE.md
3. Check: am I still building what was planned? Have I drifted?
4. Check TODO.md Concerns section -- anything accumulating?

### 5. Never Modify Tests to Pass
If a test fails, the code is wrong. Not the test. If the test is genuinely wrong (tests an outdated spec), document WHY in TODO.md Plan Amendments before changing it, and get Codex to independently confirm.

---

## Verification Tiers (Backend vs Frontend)

### Backend: Three-Gate Verification
For each requirement:

**Gate 1 -- Unit tests (process reward)**
Write tests FIRST. Run them. They must fail (red). Implement. They must pass (green). This is TDD -- not as a verbose procedure, but as the verification signal.

**Gate 2 -- Integration test (pilot)**
Start the actual system locally. Hit the real endpoints. Verify actual behavior matches acceptance criteria. Unit tests prove logic; integration tests prove the feature works.

```bash
# Example: start server, hit endpoint, check response
ssh farmshare 'source ~/selfcorr-env/bin/activate && python3 -m pytest tests/integration/ -v'
# Or locally:
curl -X POST localhost:8000/api/endpoint -d '{"test": "data"}' | jq .
```

**Gate 3 -- Cross-agent review (independent)**
Codex reviews the diff against acceptance criteria. Not "does this look right" -- "does this satisfy WHEN X, system SHALL Y."

### Frontend: Visual + Functional Verification
For each UI requirement:

**Gate 1 -- Component tests**
Unit test the components. Render, assert DOM state.

**Gate 2 -- Visual verification (Claude-in-Chrome)**
Use `mcp__claude-in-chrome__` tools to:
1. Navigate to the page (`navigate`)
2. Read the rendered page (`read_page` / `get_page_text`)
3. Interact with elements (`javascript_tool`)
4. Verify visual state matches acceptance criteria

```
# Example flow:
tabs_create_mcp → navigate to localhost:3000 → read_page → verify UI state
→ javascript_tool to interact → read_page again → confirm state change
```

**Gate 3 -- Cross-agent review**
Codex reviews the component code. Gemini reviews for accessibility/UX if relevant.

---

## The Engineering Loop

```
1. ORIENT    -- Re-read plan + TODO.md. What's next by priority?
                Every 5 iters: re-read plan, check for drift.
     |
2. RESEARCH  -- MANDATORY. COPY BEFORE REWRITE. (see below)
     |
3. DECIDE    -- Multiple approaches? Dispatch Codex + Gemini.
                Log decision in TODO.md.
     |
4. TEST FIRST -- Write failing tests for this requirement.
                Map source -> test in Test Map.
     |
5. BUILD     -- Implement FROM COPIED SOURCE. Small diffs.
                NEVER rewrite from memory.
     |
6. BACKPRESSURE -- Run ALL validators: tests, lint, types, build.
                ALL must pass. Fix until clean.
     |
7. VERIFY    -- Backend: integration test (hit real system).
                Frontend: Claude-in-Chrome visual check.
     |
8. REVIEW    -- Cross-agent review (iterative, not one-shot).
                Codex checks against acceptance criteria.
     |
9. COMMIT    -- Only after all gates pass. Update TODO.md.
     |
(back to 1, next requirement)
```

### Step 2: RESEARCH -- Copy Before Rewrite (NON-NEGOTIABLE)

Before writing ANY new code for a requirement, you MUST find and copy existing implementations. NEVER build from scratch. NEVER rewrite from memory. The code you read 5 minutes ago is already wrong in your memory.

**Search order (do ALL of these before writing a single line):**

1. **Existing repo**: Grep/Glob the current codebase. Is there already code that does this or something similar? If yes, COPY IT as your starting point.

2. **GitHub + Web**: `gh search repos "{requirement keywords}" --limit 10 --sort stars`. Also WebSearch for "{requirement} implementation github" and WebFetch promising results. Identify the best reference implementation.

3. **DeepWiki**: `mcp__deepwiki__ask_question` on the best candidate repo. Understand the actual implementation -- not the README, the SOURCE CODE. Ask: "How does {repo} implement {feature}? Show me the key functions and data structures."

4. **Copy the source**: Use `read_files_from_github_repository` or DeepWiki to read the actual implementation files. Copy them locally. If extracting from the current repo, `cp` the source files first.

5. **Then adapt**: Modify the COPIED code to fit your needs. The diff between the reference and your version should be small and explainable.

**Document in TODO.md for each requirement:**
```
### REQ-N: {name}
- Source: {repo/file the code was copied from}
- What was copied: {specific functions/classes}
- What was adapted: {specific changes and why}
- Built from scratch: {NOTHING -- or justify why no reference exists}
```

If "Built from scratch" is not "NOTHING", Codex must independently confirm no reference exists:
```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
"The agent claims no existing implementation exists for: {requirement}.
Search GitHub, your knowledge, and DeepWiki. Is this true? Or is the agent being lazy?
If you find a reference: state the repo and file path."
```

**The golden rule: if you find yourself typing a class or function from scratch when a reference exists, you are reward-hacking. Stop. Copy. Adapt.**

---

## Multi-Model Consultation

At decision points (architecture, library choice, approach pivot):

```bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
codex exec resume $CODEX_SESSION_ID --full-auto --skip-git-repo-check \
  "DECISION: {context and options}. Which approach and why?"

gemini -p "DECISION: {same context}. What would you choose? Biggest risk?"
```

- Convergence → proceed confidently
- Disagreement → investigate the disagreement before deciding
- Log everything in TODO.md Decisions section

---

## TODO.md -- The Process Reward Rubric

This is not a checklist. It IS the reward signal that keeps execution honest.

```markdown
# TODO: {Plan Name}

## Sessions
codex_session: {UUID}

## Test Map
| Requirement | Source Files | Affected Tests | Backpressure | Status |
|-------------|-------------|----------------|-------------|--------|
| REQ-1       | src/auth.py | test_auth::login | tests ✓ lint ✓ types ✓ | DONE |
| REQ-2       | src/api.py  | test_api::create | tests ✗ (line 47) | IN PROGRESS |

## Roadmap
### REQ-1: {Name} [critical]
- [x] Tests written (RED) -- Claude, iter 1
- [x] Implementation (GREEN) -- Claude, iter 2
- [x] Backpressure: tests ✓ lint ✓ types ✓ build ✓
- [x] Integration: started server, hit /api/auth, got 200
- [x] Review: Codex APPROVED -- iter 3

### REQ-2: {Name} [critical]
- [x] Tests written (RED) -- Codex, iter 2
- [ ] Implementation -- Codex, iter 4 -- ACTIVE
- [ ] Backpressure
- [ ] Integration / Visual check
- [ ] Review: Claude pending

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
```

---

## Initialize Ralph Loop

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
RALPH_PROMPT=$(mktemp /tmp/claude-execute-prompt-XXXXXX.txt)
cat > "$RALPH_PROMPT" << 'PROMPT_EOF'
You are a Principal Engineer executing an approved plan autonomously. The user is away.

AUTONOMY: Never ask the user. Consult Codex/Gemini at decision points. Only stop for missing credentials/access.

PLAN: Read the plan file at .claude/plans/ (the pre-flight already verified it exists and printed its path). Read CLAUDE.md. Read TODO.md if resuming. If NO plan file exists, STOP immediately -- do not guess what to build.

ANTI-REWARD-HACKING:
1. Backpressure: ALL validators (tests, lint, types, build) must pass before EVERY commit. No exceptions.
2. Test map: for each requirement, map source files -> affected tests in TODO.md. This is your process reward.
3. Cross-agent review: you cannot self-certify. Codex reviews your work iteratively (review -> fix -> re-review -> converge).
4. Re-injection: every 5 iterations, re-read the plan and CLAUDE.md. Check for drift.
5. COPY BEFORE REWRITE: Before writing ANY new code, search the existing repo (Grep/Glob), GitHub (gh search), and DeepWiki for reference implementations. COPY the actual source files. Adapt from copied code. NEVER rewrite from memory. If no reference exists, Codex must independently confirm this. Document source for every requirement in TODO.md.
6. Never modify tests to make them pass. If a test fails, the code is wrong.
5. Never modify tests to make them pass. If a test fails, the code is wrong.

VERIFICATION:
- Backend: unit tests (TDD) → integration test (start system, hit endpoints) → cross-agent review
- Frontend: component tests → Claude-in-Chrome visual verification → cross-agent review

LOOP: For each requirement by priority:
1. ORIENT -- re-read plan + TODO.md
2. RESEARCH (NON-NEGOTIABLE) -- BEFORE writing any code:
   a. Grep/Glob existing repo for similar code. If found, COPY it.
   b. gh search repos + WebSearch + WebFetch for reference implementations.
   c. DeepWiki on best candidate -- read the SOURCE, not the README.
   d. Copy actual source files locally. Document in TODO.md: what was copied, from where, what needs adapting.
   e. If truly nothing exists, have Codex independently confirm.
   NEVER skip this step. NEVER write from scratch when a reference exists.
3. DECIDE -- if multiple approaches, consult Codex + Gemini, log decision
4. TEST FIRST -- write failing tests, add to test map
5. BUILD -- implement FROM COPIED SOURCE. Adapt, don't rewrite. Small diffs.
6. BACKPRESSURE -- run all validators, fix until clean
7. VERIFY -- backend: integration. frontend: chrome visual check
8. REVIEW -- iterative cross-agent review (review -> fix -> re-review). Not one-shot.
9. COMMIT -- only after all gates pass. Update TODO.md.

COMPLETION: When ALL requirements pass ALL gates:
1. Write Walkthrough section in TODO.md
2. Update CLAUDE.md with lessons learned
3. Verify build + lint + types clean one final time

<promise>ALL_REQUIREMENTS_VERIFIED</promise>
If blocked: <promise>BLOCKED: [reason]</promise>
PROMPT_EOF
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "ALL_REQUIREMENTS_VERIFIED" \
  "$(cat "$RALPH_PROMPT")"
rm -f "$RALPH_PROMPT"
```

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
echo "═══════════════════════════════════════════════════════════════════"
echo "AUTONOMOUS MODE -- User is away. Consulting Codex/Gemini at decisions."
echo ""
echo "Anti-reward-hacking: backpressure validators, test map, cross-agent review"
echo "Promise: ALL_REQUIREMENTS_VERIFIED"
echo ""
echo "This means: ALL gates passed, not 'it looks done'."
echo "Tests passing ≠ feature working. Run the system. See it work."
echo "═══════════════════════════════════════════════════════════════════"
```
