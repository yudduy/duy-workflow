---
description: Deep codebase exploration + structured interview to generate a spec file
argument-hint: "[feature description]"
---

# /interview

Generate an unambiguous SPEC.md through codebase exploration, structured interview, and verification.

**IMPORTANT:** This skill uses **plan mode**. Enter plan mode immediately at the start. All exploration, interviewing, and spec drafting happen inside plan mode. Only exit plan mode once the spec is finalized and the user approves.

---

## STEP 0: ENTER PLAN MODE + CREATE TODO LIST

**Immediately call `EnterPlanMode`** before doing anything else.

Then create a todo list using `TaskCreate` to track progress through all phases:

1. "Explore codebase for architecture, patterns, and conventions"
2. "Conduct structured interview with user"
3. "Generate SPEC.md from interview answers"
4. "Verify spec against codebase and SOTA research"
5. "Get user approval and hand off to /execute"

Mark each task as `in_progress` when starting it and `completed` when done.

---

## PHASE 1: CODEBASE EXPLORATION

Before asking questions, understand the codebase.

**Quick orientation:**
```bash
ls -la && ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
git log --oneline -10 2>/dev/null
```

**Parallel exploration** (Task tool, Explore subagents):
- Architecture: structure, entry points, patterns
- Testing: frameworks, conventions, existing test examples
- Dependencies: external integrations, APIs
- Existing CLAUDE.md: read the project's CLAUDE.md (at the **git repo root**, not home directory) for patterns, anti-patterns, and gotchas

**Web search:** `[framework] best practices`, `[feature domain] patterns`

**Summarize findings** before moving to interview. Present a brief architecture overview to the user so they can correct any misunderstandings early.

---

## PHASE 2: STRUCTURED INTERVIEW

**ALWAYS use AskUserQuestion tool** - never plain text questions.

Conduct **multiple rounds** until all ambiguity is resolved. Do not rush.

- 2-4 questions per round
- `multiSelect: true` for features/capabilities
- `multiSelect: false` for either/or decisions
- Include descriptions explaining trade-offs
- Reference specific code/patterns discovered in Phase 1 to ground questions

**Categories to cover (do not skip any):**
- **Requirements:** capabilities, user scenarios, integrations
- **Constraints:** patterns to follow, performance requirements, existing conventions
- **Approach:** technical decisions, priorities, which existing code to reuse
- **Edge cases:** error scenarios, boundary conditions, failure modes
- **Verification:** acceptance criteria, completion tests, what "done" looks like
- **Scope boundaries:** what is explicitly NOT in scope

**After each round:** Summarize what you've learned and identify remaining gaps. Continue interviewing until you can write every requirement without guessing.

**Final question — Execution Strategy:**

After all requirements are gathered, assess the spec scope and ask ONE final question.

Skip this question (default to "Subagent delegation") if:
- 3 or fewer REQs
- All REQs touch the same files

Otherwise, use AskUserQuestion:
```
header: "Execution"
question: "This spec has [N] requirements across [layers]. How should it be executed?"
options:
  - label: "Subagent delegation (Recommended)"
    description: "Orchestrator + subagents, sequential TDD. Best cost/speed balance."
  - label: "Agent team"
    description: "[N] independent REQ groups detected. Parallel execution across [M] teammates. ~[X]x token cost but faster wall-clock."
  - label: "Solo"
    description: "Single agent, no delegation. Lowest cost for small changes."
```

Fill in `[N]`, `[M]`, `[X]` with actual counts from your analysis. Group independent REQs by file-overlap — REQs sharing files must stay in the same group.

---

## PHASE 3: SPEC GENERATION

**Output:** `docs/specs/{feature-name}.spec.md`

```markdown
# Specification: [Feature Name]

> To implement this spec, clear context and run:
> `/duy-workflow:execute docs/specs/{this-file}.spec.md`

## Goal
[One sentence]

## Requirements
1. **[REQ-1]** [Testable requirement]
   - Acceptance: [How to verify]

## Design Decisions
| Decision | Choice | Rationale |

## Completion Criteria
- [ ] All REQs implemented with passing tests
- [ ] Build + lint clean

## Edge Cases
| Case | Expected Behavior |

## Out of Scope
- [Explicitly excluded items]

## Technical Context
### Key Files
- `[path]`: [purpose]

### Patterns to Follow
- [discovered patterns from codebase and CLAUDE.md]

## Execution Strategy
**Mode:** [solo | subagent | team]
**REQ Groups:** (only for team mode)
| Group | REQs | Layer | Files |
```

---

## PHASE 4: SPEC VERIFICATION

**Before /duy-workflow:execute:** Verify each requirement against reality.

### Step 1: SOTA Research
Parallel Explore subagents for best practices, current docs, pitfalls.

### Step 2: Codebase Verification
One Explore subagent per REQ (parallel):
- Verify implementability given current codebase
- Identify files to modify
- Check for existing reusable functions (avoid duplication)
- Flag conflicts or missing dependencies

### Step 3: Report & Iterate
Present conflicts/gaps found.

**If new issues discovered:** Loop back to Phase 2 (ask clarifying questions via AskUserQuestion), then update spec in Phase 3.

**When clean:** Wait for user confirmation before /duy-workflow:execute.

### Step 4: Update Spec
Add to spec file:
- File paths to be modified
- Documentation links
- Adjusted requirements

**Principle:** Keep implementation minimal—only requested changes.

---

## HANDOFF

Present the final spec to the user. Use `ExitPlanMode` to exit plan mode.

```
Spec verified: docs/specs/{feature-name}.spec.md
- [N] requirements verified against codebase
- Conflicts: [none or list]

To implement, clear context and run:
  /duy-workflow:execute docs/specs/{feature-name}.spec.md
```

**Always remind the user** to run `/duy-workflow:execute` (or just `/execute`) with the spec path. This is the next step after interview.
