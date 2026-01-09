# CLAUDE.md

> This file is read by Claude Code at the start of every session. It captures project context, patterns, and lessons learned. **Update this file whenever Claude makes a mistake or you discover something important.**

## Project Overview

<!-- Brief description of what this project does -->
**Project:** [PROJECT_NAME]
**Tech Stack:** [e.g., Next.js, TypeScript, PostgreSQL, Tailwind]
**Purpose:** [One sentence describing the project's goal]

## Quick Start

```bash
# Install dependencies
[npm install / pnpm install / etc.]

# Run development server
[npm run dev / etc.]

# Run tests
[npm test / etc.]
```

## Architecture

<!-- High-level architecture overview -->
```
src/
├── components/    # React components
├── lib/           # Shared utilities
├── pages/         # Next.js pages (or routes/)
├── api/           # API routes
└── types/         # TypeScript types
```

## Key Patterns

<!-- Document patterns Claude should follow -->

### Code Style
- [e.g., Use functional components with hooks]
- [e.g., Prefer named exports over default exports]
- [e.g., Use kebab-case for file names]

### Testing
- [e.g., Co-locate tests with source files: `foo.ts` → `foo.test.ts`]
- [e.g., Use React Testing Library, not Enzyme]
- [e.g., Mock external APIs in `__mocks__/`]

### State Management
- [e.g., Use React Query for server state]
- [e.g., Use Zustand for client state]

## Workflows

### Creating a Feature
```
1. /interview "feature description"  → generates docs/specs/{feature}.spec.md
2. /execute docs/specs/{feature}.spec.md → implements with TDD
3. /commit → creates commit with changes
4. /pr → creates pull request
```

### Daily Development
- Start with `/execute` for spec-driven work
- Use `&` to hand off tasks to web Claude while you review
- Use `/tp` to pull web sessions back to terminal

## Anti-Patterns (DO NOT DO)

<!-- Add mistakes here when Claude makes them -->

| Date | Mistake | Correct Approach |
|------|---------|------------------|
| YYYY-MM-DD | [What Claude did wrong] | [What it should do instead] |

### Common Mistakes
- [ ] **Don't use deprecated APIs** - [specific example if applicable]
- [ ] **Don't add unnecessary dependencies** - check if existing libs can do it
- [ ] **Don't skip tests** - every feature needs tests

## Project-Specific Rules

<!-- Rules unique to this project -->

### Naming Conventions
- Components: `PascalCase.tsx`
- Hooks: `useCamelCase.ts`
- Utils: `camelCase.ts`
- Constants: `SCREAMING_SNAKE_CASE`

### Database
- [e.g., Always use migrations, never modify schema directly]
- [e.g., Use Prisma for all database access]

### API Design
- [e.g., REST endpoints follow `/api/v1/resource` pattern]
- [e.g., Always return consistent error format]

## Environment Variables

<!-- Document required env vars without actual values -->
```
DATABASE_URL=       # PostgreSQL connection string
NEXT_PUBLIC_API=    # Public API base URL
SECRET_KEY=         # JWT signing key
```

## Gotchas

<!-- Non-obvious things that have tripped people up -->

- [e.g., "The `auth` middleware must come before `cors` in the stack"]
- [e.g., "Tests fail if you don't clear the database between runs"]
- [e.g., "The deploy script expects `main` branch, not `master`"]

## External Services

| Service | Purpose | Docs |
|---------|---------|------|
| [e.g., Stripe] | [Payments] | [link] |
| [e.g., SendGrid] | [Email] | [link] |

## Team Conventions

<!-- For shared repos -->

- **PR titles:** `[type]: description` (e.g., `[feat]: add user auth`)
- **Commit style:** [Conventional Commits / other]
- **Branch naming:** `type/description` (e.g., `feat/user-auth`)

---

## Changelog

<!-- Track significant CLAUDE.md updates -->

| Date | Change |
|------|--------|
| YYYY-MM-DD | Initial CLAUDE.md created |
