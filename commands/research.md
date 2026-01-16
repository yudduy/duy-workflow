---
description: Ralph-powered deep research exploration - exhaustively discovers and maps concepts, papers, implementations
argument-hint: "<topic> [--max-iterations N]"
allowed-tools: Task, WebSearch, WebFetch, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /research

Ralph-powered exhaustive research on a topic. Continues until knowledge base is complete.

## Setup

```bash
mkdir -p docs/research/{topic-slug}/notes
```

Initialize `docs/research/{topic}/KNOWLEDGE.md`:
```markdown
# Research: {Topic}
> Started: {timestamp}

## Summary
[To be filled after exploration]

## Concepts
| Concept | Definition | Source |

## Literature
| Paper | Authors | Year | Key Contribution | URL |

## Methods
| Technique | Description | When to Use |

## Implementations
| Name | Language | Purpose | URL |

## Gaps
| Gap | Impact | Potential Approaches |

## Progress
| Area | Status | Notes |
```

## Ralph Loop

```!
"${CLAUDE_PLUGIN_ROOT}/../superpowers/scripts/setup-ralph-loop.sh" \
  --max-iterations "${MAX_ITER:-100}" \
  --completion-promise "RESEARCH_EXHAUSTED" \
  "Exhaustively research {topic}. You are a research orchestrator.

## Each Iteration:
1. READ docs/research/{topic}/KNOWLEDGE.md for current state
2. IDENTIFY gaps: missing concepts, unread papers, unexplored areas
3. DELEGATE parallel Explore agents to fill gaps:
   - WebSearch for papers, implementations, discussions
   - WebFetch to read actual content (not just summaries)
   - One agent per knowledge gap
4. SYNTHESIZE findings into KNOWLEDGE.md
5. UPDATE progress table

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

## Completion:
When ALL of these are true:
- Core concepts documented with multiple sources
- Seminal papers read and summarized
- Key implementations catalogued
- Research gaps explicitly identified
- No obvious unexplored threads
THEN: <promise>RESEARCH_EXHAUSTED</promise>

If genuinely stuck: <promise>BLOCKED: [reason]</promise>"
```

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
- Note related concepts
- Return: definition, sources, connections"
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
