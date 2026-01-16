---
description: Ralph-powered mind map generation - exhaustively maps concept relationships from knowledge base
argument-hint: "<topic> [--max-iterations N]"
allowed-tools: Task, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# /map

Ralph-powered mind map generation. Exhaustively maps all concepts and relationships.

## Setup

Locate knowledge base:
```bash
ls docs/research/
```

If topic not specified, ask:
```
AskUserQuestion: "Which research topic should I map?"
```

Read `docs/research/{topic}/KNOWLEDGE.md`.

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/../superpowers/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-50}" \
  --completion-promise "MAP_COMPLETE" \
  "Generate exhaustive mind map from docs/research/{topic}/KNOWLEDGE.md.

## Each Iteration:
1. READ KNOWLEDGE.md and existing MINDMAP.md (if any)
2. EXTRACT concepts not yet mapped
3. IDENTIFY relationships between concepts:
   - Hierarchical: 'X is type of Y'
   - Dependency: 'X uses Y'
   - Similarity: 'X similar to Y'
   - Causal: 'X leads to Y'
   - Conflict: 'X contradicts Y'
4. UPDATE MINDMAP.md with new nodes and edges
5. CHECK completeness: every KNOWLEDGE.md concept in map?

## Mind Map Structure:
\`\`\`markdown
# Mind Map: {Topic}

## Core
{Topic}
├── Branch 1
│   ├── Concept A → related to [[Concept B]]
│   └── Concept C
└── Branch 2

## Connections
- [[A]] ←uses→ [[B]]: {why}
- [[C]] ←contradicts→ [[D]]: {nature}

## Gaps (from KNOWLEDGE.md)
- [ ] Gap 1: {description}

## Learning Path
1. Start: {foundational concept}
2. Then: {next concepts}
3. Deep dive: {advanced}
\`\`\`

## Completeness Rules:
- Every concept in KNOWLEDGE.md appears in map
- Every relationship explicitly labeled
- No orphan nodes (everything connected)
- All gaps from KNOWLEDGE.md listed
- Learning path reflects actual dependencies

## Completion:
When map is complete and consistent:
<promise>MAP_COMPLETE</promise>"
```

## Output

After completion:
```
Mind Map: docs/research/{topic}/MINDMAP.md
- Concepts: {N}
- Connections: {M}
- Gaps: {G}
```
