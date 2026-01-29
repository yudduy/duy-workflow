---
description: Ralph-powered deep research exploration - exhaustively discovers and maps concepts, papers, implementations
argument-hint: "<topic> [--map] [--exhaustive] [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /research

Ralph-powered exhaustive research on a topic. Continues until knowledge base is complete.

## Flags

- `--map`: Auto-generate MINDMAP.md after research completes
- `--exhaustive`: Full output (no caps on implementations/papers)
- `--max-iterations N`: Override default iteration limit (default: 100)

## Setup

```bash
mkdir -p docs/research/{topic-slug}/notes
```

Initialize `docs/research/{topic}/KNOWLEDGE.md` (compact format):
```markdown
# Research: {Topic}
> Started: {timestamp}

## Summary
[To be filled after exploration]

## Core Concepts
- **Concept**: Definition (Source)

## Key Literature
- **Paper Title** (Authors, Year): Key contribution. [URL]

## Methods & Techniques
- **Technique**: When to use, brief description

## Implementations
- **Name** (Language): Purpose. [URL]

## Open Gaps
- Gap description - Impact - Potential approaches

## Connections
- [[Concept A]] -- relates to --> [[Concept B]]: {why}
- [[Method X]] -- implements --> [[Concept Y]]: {how}

## Progress
- [ ] Area 1
- [ ] Area 2
```

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "RESEARCH_EXHAUSTED" \
  "Exhaustively research {topic}. You are a research orchestrator.

## RESEARCH PROTOCOL

Before adding any item to KNOWLEDGE.md, verify it:
1. STATE the finding explicitly
2. CITE the source (URL, paper, or multiple corroborating sources)
3. ASSESS confidence: is this from a primary source, secondary summary, or inference?
4. CROSS-REFERENCE: does this connect to or contradict anything already in KNOWLEDGE.md?

When you find contradictory information from different sources:
- Document BOTH viewpoints with citations
- Note the contradiction explicitly in KNOWLEDGE.md
- Assess which source is more authoritative and why

## Each Iteration:
1. READ docs/research/{topic}/KNOWLEDGE.md for current state
2. IDENTIFY gaps using systematic decomposition:
   - What sub-topics have zero coverage?
   - What claims have only one source? (need 2+)
   - What connections between concepts are unexplored?
   - What recent developments (last 12 months) are missing?
3. PRIORITIZE gaps by impact:
   - Core concepts with missing definitions: HIGH
   - Seminal papers not yet read: HIGH
   - Implementation details: MEDIUM
   - Tangential connections: LOW
4. DELEGATE parallel Explore agents to fill HIGH-priority gaps:
   - WebSearch for papers, implementations, discussions
   - WebFetch to read actual content (not just summaries)
   - One agent per knowledge gap
5. SYNTHESIZE findings into KNOWLEDGE.md (compact bullet format)
6. UPDATE Connections section - every new concept should link to at least one existing concept
7. UPDATE progress checklist

## Output Rules:
- Use bullet lists, not tables (more compact)
- Cap to top 10 most relevant items per section (unless --exhaustive)
- No empty placeholders - only add items with real content
- One line per item where possible
- Every item must have a source citation

## Exhaustiveness Rules:
- For each paper found: read abstract AND methodology
- For each concept: find 2+ sources confirming definition
- For each implementation: verify it exists (check GitHub stars, recent commits)
- Follow citation chains: if Paper A cites Paper B, research Paper B
- Cross-reference: if Concept X relates to Y, ensure both documented

## Quality Gates:
- No paper listed without reading its abstract
- No concept without definition AND source
- No implementation without verified URL
- All gaps either filled or marked BLOCKED with reason
- Every concept connected to at least one other concept in Connections section
- Contradictions between sources explicitly noted

## Self-Assessment (each iteration):
Before deciding whether to continue or stop, answer:
- What is the single biggest gap remaining?
- Would filling that gap change the Summary section?
- Am I finding genuinely new information, or re-confirming what I already know?
If the last 2 iterations produced no substantive new findings, strongly consider stopping.

## Completion:
When ALL of these are true:
- Core concepts documented with multiple sources
- Seminal papers read and summarized
- Key implementations catalogued
- Research gaps explicitly identified
- Connections section maps relationships between concepts
- No obvious unexplored threads
THEN: <promise>RESEARCH_EXHAUSTED</promise>

If genuinely stuck: <promise>BLOCKED: [reason]</promise>"
```

## Post-Research: Mind Map Generation (--map flag)

If `--map` flag was specified, after RESEARCH_EXHAUSTED:

```
Read docs/research/{topic}/KNOWLEDGE.md and generate docs/research/{topic}/MINDMAP.md:

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
```

Rules for mind map:
- Every concept in KNOWLEDGE.md appears in map
- Every relationship explicitly labeled
- No orphan nodes (everything connected)
- Learning path reflects actual dependencies

## Parallel Agent Templates

### Literature Agent
```
Task (Explore): "Find papers on {subtopic}:
- WebSearch: '{subtopic} paper arxiv'
- For top 5 results: WebFetch abstract and contributions
- Return: title, authors, year, key contribution, URL"
```

### Concepts Agent
```
Task (Explore): "Define {concept}:
- Find 2+ authoritative sources
- Extract precise definition
- Note related concepts and any contradictory definitions across sources
- Return: definition, sources, connections, contradictions (if any)"
```

### Implementations Agent
```
Task (Explore): "Find implementations of {method}:
- WebSearch: '{method} github implementation'
- Verify repos exist and are maintained
- Return: name, language, stars, last updated, URL"
```

### Gaps Agent
```
Task (Explore): "Identify gaps in {area}:
- WebSearch: '{area} open problems' OR '{area} future work'
- Find recent discussions (blogs, forums, Twitter)
- Return: gap description, why unsolved, potential approaches"
```

### Cross-Reference Agent
```
Task (Explore): "Find connections between {concept_a} and {concept_b}:
- WebSearch: '{concept_a} {concept_b} relationship'
- Look for: causal links, shared foundations, contradictions, implementations
- Return: relationship type, evidence, sources"
```

## Output

After completion:
```
Research complete: docs/research/{topic}/KNOWLEDGE.md
- Concepts: {N}
- Papers: {M}
- Implementations: {I}
- Connections: {C}
- Gaps: {G}
[If --map] Mind map: docs/research/{topic}/MINDMAP.md
```
