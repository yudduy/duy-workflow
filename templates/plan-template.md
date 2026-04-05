---
plan_id: {PLAN_ID}
created: {ISO 8601 timestamp}
status: approved
---

# Product Intent: {Name}

## The Job
[Who is the user? What job are they hiring this to do? Before/after state.]

## The Announcement
[One paragraph. The launch tweet. If this isn't compelling, the vision isn't clear.]

## The Appetite
[How much complexity is this worth? Rough solution shape. Time box.]

## Out of Scope
[Explicit. With WHY for each exclusion.]

## Principles
[Non-negotiable product values. Decision heuristics for ambiguous situations.]
- Always {X} over {Y}
- Never {Z}
- When in doubt, choose {A}

## Decision Precedence
When /execute faces an ambiguous choice, apply in this order:
1. Invariants (must not break)
2. Guardrails (hard limits)
3. Explicit acceptance criteria
4. Principles (above)
5. Source Map reference behavior
6. Simpler / more reversible option

## Boundaries
- **Success**: {how we know it worked}
- **Invariants**: {what must not break}
- **Guardrails**: {hard limits}
- **Stop rules**: {when to escalate vs decide}

## Requirements (ordered by priority)
| ID | Name | Acceptance Criteria | Priority |
|----|------|-------------------|----------|
| REQ-1 | {name} | WHEN {trigger}, system SHALL {behavior} | critical |
| REQ-2 | {name} | WHEN {trigger}, system SHALL {behavior} | high |
| REQ-3 | {name} | WHEN {trigger}, system SHALL {behavior} | medium |

## Key Decisions (with WHY)
| Decision | Choice | Why | Alternatives Considered |
|----------|--------|-----|------------------------|

## Approach
[Which existing implementation to scaffold from. What to extract/adopt/build.]

## Source Map (CRITICAL -- /execute uses this to copy before rewrite)
| Requirement | Reference Source | Repo/File | What to Copy | What to Adapt |
|-------------|----------------|-----------|-------------|---------------|
| REQ-1 | {existing repo or internal code} | {github.com/x or local path} | {specific classes/functions} | {what needs changing} |

## Build Environment
- **Language/Runtime**: {e.g., Python 3.12, Node 22}
- **Test command**: {e.g., pytest tests/ -v}
- **Lint command**: {e.g., ruff check .}
- **Type check command**: {e.g., mypy src/}
- **Build command**: {e.g., npm run build}
- **Start command**: {e.g., python -m uvicorn main:app}
- **Integration test**: {e.g., pytest tests/integration/ -v}

## Knowledge Map
[Persisted research -- one row per source, verified, with implications]

## The Why Behind Everything
[The reasoning chain. If an agent reads only this section, it should understand
the product deeply enough to make aligned decisions the document doesn't cover.]
