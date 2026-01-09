---
description: Add a mistake/anti-pattern to CLAUDE.md (compounding engineering)
argument-hint: "[description of what went wrong]"
---

# /add-mistake

Quickly add a mistake or anti-pattern to CLAUDE.md so Claude doesn't repeat it.

This implements Boris's "compounding engineering" pattern: every time Claude does something wrong, document it so it doesn't happen again.

## Usage

```
/add-mistake "Claude used deprecated useState syntax instead of useReducer for complex state"
/add-mistake "Added moment.js when date-fns was already installed"
/add-mistake "Didn't run tests before committing"
```

## Process

When the user provides a mistake description:

1. **Read CLAUDE.md** to find the Anti-Patterns table
2. **Ask clarifying questions** (via AskUserQuestionTool):
   - What should Claude do instead?
   - Is this a one-time mistake or a pattern to always avoid?
3. **Add to the table** with today's date
4. **Confirm** the addition

## Example Addition

If the user says: `/add-mistake "Used any type instead of proper typing"`

Add to the Anti-Patterns table in CLAUDE.md:

```markdown
| 2026-01-08 | Used `any` type instead of proper TypeScript typing | Always define explicit types; use `unknown` if truly unknown |
```

## If No CLAUDE.md Exists

```
No CLAUDE.md found in this project.

Run /new-project first to create the project structure,
or create CLAUDE.md manually.
```

## Compounding Engineering

This is how teams build institutional knowledge:
- Each mistake becomes a documented lesson
- Claude reads CLAUDE.md every session
- Over time, Claude makes fewer project-specific mistakes
- New team members (and Claude) benefit from accumulated wisdom

**Commit CLAUDE.md changes** so the whole team benefits!
