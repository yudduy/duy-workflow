---
description: Deep codebase exploration + structured interview to generate a spec file
argument-hint: "[feature description]"
---

# /interview

Generate an unambiguous SPEC.md through codebase exploration, structured interview, and verification.

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
- Testing: frameworks, conventions
- Dependencies: external integrations, APIs

**Web search:** `[framework] best practices`, `[feature domain] patterns`

---

## PHASE 2: STRUCTURED INTERVIEW

**ALWAYS use AskUserQuestion tool** - never plain text questions.

- 2-4 questions per round
- `multiSelect: true` for features/capabilities
- `multiSelect: false` for either/or decisions
- Include descriptions explaining trade-offs

**Categories to cover:**
- Requirements: capabilities, user scenarios, integrations
- Constraints: patterns to follow, performance requirements
- Approach: technical decisions, priorities
- Edge cases: error scenarios, boundary conditions
- Verification: acceptance criteria, completion tests

---

## PHASE 3: SPEC GENERATION

**Output:** `docs/specs/{feature-name}.spec.md`

```markdown
# Specification: [Feature Name]

> Use `/duy-workflow:execute docs/specs/{this-file}.spec.md` to implement.

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

## Technical Context
### Key Files
- `[path]`: [purpose]

### Patterns to Follow
- [discovered patterns]
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

```
Spec verified: docs/specs/{feature-name}.spec.md
- [N] requirements verified against codebase
- Conflicts: [none or list]
- Ready for: /duy-workflow:execute docs/specs/{feature-name}.spec.md
```
