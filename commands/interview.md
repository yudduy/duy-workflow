---
description: Deep codebase exploration + structured interview to generate SPEC.md
argument-hint: "[feature description]"
---

# /interview

**Purpose:** Deeply explore the codebase, then conduct a structured interview using AskUserQuestionTool to generate an unambiguous SPEC.md ready for autonomous execution.

---

## CRITICAL RULE: ALWAYS USE AskUserQuestionTool

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  NEVER ask questions as plain text.                                       ║
║  ALWAYS use AskUserQuestionTool for EVERY question.                       ║
║                                                                           ║
║  This gives users the toggle/checkmark interface to select options.       ║
║  Plain text questions are PROHIBITED during the interview phase.          ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

**Why:** The structured selection interface ensures:
- Clear, unambiguous user choices
- Multi-select for features/capabilities
- Single-select for either/or decisions
- Descriptions explain trade-offs for each option

---

## PHASE 1: CODEBASE UNDERSTANDING

Before asking ANY questions, you MUST understand the codebase thoroughly. This exploration enables informed, intelligent questions.

### Step 1: Quick Orientation (2-3 min)

```bash
# Project structure
ls -la && find . -type d -name "src" -o -name "lib" -o -name "packages" 2>/dev/null | head -20

# Project type
ls package.json pyproject.toml Cargo.toml go.mod pom.xml requirements.txt 2>/dev/null

# Existing docs
ls README* CLAUDE.md AGENTS.md docs/ 2>/dev/null

# Recent activity
git log --oneline -15 2>/dev/null || echo "Not a git repo"
```

### Step 2: Parallel Deep Exploration

Dispatch 3-5 exploration agents simultaneously using the Task tool:

| Agent | Focus | Key Questions |
|-------|-------|---------------|
| **Architecture** | Core structure, entry points, patterns | How is code organized? What are the main abstractions? |
| **Testing** | Test infrastructure, conventions, coverage | How are tests structured? What frameworks are used? |
| **Git History** | Hot files, recent changes, active areas | What's changing frequently? Who's working on what? |
| **Dependencies** | External integrations, APIs, databases | What external systems exist? How do they connect? |
| **Domain** | Business logic, vocabulary, edge cases | What's the domain model? What terminology is used? |

### Step 3: Web Search for Context

**MANDATORY:** Search for best practices before interviewing.

```
WebSearch: "[framework detected] best practices 2025"
WebSearch: "[feature domain] implementation patterns"
WebSearch: "[feature domain] common pitfalls"
```

### Step 4: Anti-Pattern Guards

Before proceeding to interview, verify:

- [ ] Traced at least ONE feature end-to-end through the codebase
- [ ] Read test files to understand expected behaviors
- [ ] Checked hidden config (.env.example, CI configs, etc.)
- [ ] Identified entry points and main data flows
- [ ] Mapped key dependency relationships
- [ ] Understand existing naming conventions

**If any are unchecked, continue exploring before interviewing.**

---

## PHASE 2: STRUCTURED INTERVIEW

### Interview Rules

1. **ALWAYS use AskUserQuestionTool** - Never ask questions as plain text
2. **2-4 questions per round** - Don't overwhelm
3. **Context-appropriate selection:**
   - `multiSelect: true` for feature/capability selection ("Which features should this include?")
   - `multiSelect: false` for either/or decisions ("Which approach should we take?")
4. **Include descriptions** - Each option should explain trade-offs
5. **Continue until exhaustive clarity**

### Question Categories

Use these categories to ensure complete coverage:

#### Requirements (multiSelect: true usually)
```
"What capabilities should this feature include?"
"Which user scenarios must be supported?"
"What integrations are needed?"
```

#### Constraints (multiSelect: true usually)
```
"Which constraints apply to this implementation?"
"What existing patterns must we follow?"
"Are there performance/scale requirements?"
```

#### Approach (multiSelect: false usually)
```
"Which technical approach should we take?"
"Option A vs Option B - which fits better?"
"Should we prioritize X or Y?"
```

#### Edge Cases (multiSelect: true usually)
```
"Which error scenarios need handling?"
"What happens when [boundary condition]?"
"How should we handle [failure mode]?"
```

#### Verification (multiSelect: false usually)
```
"How will we know this is complete?"
"What are the acceptance criteria?"
"What tests prove this works?"
```

### Interview Flow

```
1. Present your understanding (1-2 sentences based on exploration)
2. Ask 2-4 focused questions via AskUserQuestionTool
3. Incorporate answers into understanding
4. If unclear areas remain, ask follow-up questions
5. Repeat until all categories covered
6. Present final understanding for confirmation
7. Generate SPEC.md
```

### Clarity Signals (Ready to Generate Spec)

Move to spec generation when:
- Core approach agreed
- All major capabilities confirmed via structured questions
- Edge cases identified
- Completion criteria defined
- Integration points mapped
- User confirms understanding is correct

---

## PHASE 3: SPEC GENERATION

### Output: docs/SPEC.md

Create a comprehensive specification:

```markdown
# Specification: [Feature Name]

> **For Claude:** Use `/execute` to implement this spec autonomously.

## Goal
[One sentence describing the desired outcome]

## Requirements

### Core Requirements
1. **[REQ-1]** [Requirement with testable criteria]
   - Acceptance: [How to verify]
2. **[REQ-2]** [Requirement with testable criteria]
   - Acceptance: [How to verify]

### Optional Requirements (from user selections)
3. **[REQ-3]** [Optional feature selected by user]
   - Acceptance: [How to verify]

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Architecture choice] | [What we chose] | [Why, based on interview] |
| [Technology choice] | [What we chose] | [Why, based on codebase patterns] |

## Completion Criteria

All of these must be true for completion:

- [ ] All [REQ-*] requirements implemented with passing tests
- [ ] All tests passing (unit, integration)
- [ ] Build clean (no errors)
- [ ] Lint clean (no warnings)
- [ ] Code follows existing patterns discovered in exploration
- [ ] No security vulnerabilities introduced

## Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| [Error scenario from interview] | [How to handle] |
| [Boundary condition] | [Expected outcome] |

## Integration Points

| System | Integration Method | Notes |
|--------|-------------------|-------|
| [External API/DB/Service] | [REST/GraphQL/ORM/etc] | [Key considerations] |

## Out of Scope

Explicitly NOT included in this implementation:
- [Feature/capability explicitly excluded]
- [Future enhancement deferred]

## Technical Context (from exploration)

### Key Files
- `[path]`: [Purpose discovered]
- `[path]`: [Purpose discovered]

### Existing Patterns to Follow
- [Naming convention discovered]
- [Architecture pattern discovered]
- [Testing pattern discovered]

### Gotchas Discovered
- [Non-obvious behavior found during exploration]
```

---

## HANDOFF

After generating SPEC.md:

```
Specification complete: docs/SPEC.md

Summary:
- [N] core requirements
- [M] optional requirements
- [X] completion criteria checkpoints
- Key integration: [main integration point]

Interview covered:
- Requirements ✓
- Constraints ✓
- Approach ✓
- Edge cases ✓
- Verification ✓

Ready for `/execute` to begin autonomous implementation?
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Ask questions as plain text | Use AskUserQuestionTool |
| Ask 10+ questions at once | 2-4 questions per round |
| Skip codebase exploration | Explore deeply before interviewing |
| Assume you understand | Verify with structured questions |
| Generate vague requirements | Each requirement must be testable |
| Skip edge cases | Explicitly ask about failure modes |
| Ignore existing patterns | Document discovered patterns in spec |

---

## Example Interview Flow

```
User: "Add user authentication"

Claude: [Explores codebase - finds Express, PostgreSQL, existing user model]

Claude: I've explored the codebase. I see you're using Express with PostgreSQL,
and there's an existing User model in src/models/. Let me ask some questions
to clarify the requirements.

[AskUserQuestionTool]
Question: "Which authentication methods should be supported?"
multiSelect: true
Options:
- Email/password (standard login form)
- OAuth - Google (social login)
- OAuth - GitHub (developer-focused)
- Magic link (passwordless email)

[User selects: Email/password, OAuth - Google]

[AskUserQuestionTool]
Question: "Which session management approach should we use?"
multiSelect: false
Options:
- JWT tokens (stateless, scales horizontally) [Recommended based on your API patterns]
- Server sessions (stateful, simpler but requires session store)

[User selects: JWT tokens]

[AskUserQuestionTool]
Question: "Which security features are required?"
multiSelect: true
Options:
- Password strength validation
- Rate limiting on login attempts
- Account lockout after failed attempts
- Two-factor authentication (2FA)

[Continues until all categories covered...]

Claude: Based on our interview, here's my understanding:
- Email/password + Google OAuth authentication
- JWT tokens for session management
- Password validation + rate limiting (no 2FA for MVP)
- Integration with existing User model

Is this correct? [Generates SPEC.md on confirmation]
```
