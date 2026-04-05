---
description: "Crystallize vague intuitions into precise intent. Research-first, multi-model synthesis, maieutic elicitation. Routes to /interview (build) or /research (understand)."
argument-hint: "<vague idea or intuition>"
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Agent, mcp__deepwiki__ask_question, mcp__deepwiki__read_wiki_structure, mcp__claude_ai_alphaxiv__embedding_similarity_search, mcp__claude_ai_alphaxiv__full_text_papers_search, mcp__claude_ai_alphaxiv__agentic_paper_retrieval, mcp__claude_ai_alphaxiv__get_paper_content, mcp__claude_ai_alphaxiv__answer_pdf_queries, mcp__claude_ai_alphaxiv__read_files_from_github_repository
---

# /brainstorm

Turn a vague intuition into a precise intent. The user has a half-formed idea — your job is to crystallize it into something /interview or /research can execute autonomously.

**This is the "zero to one" phase.** The user doesn't know exactly what they want yet. You help them find out — but you do the work of understanding the landscape BEFORE asking them anything.

## Foundational Rigors

**Three-Question Audit** (`${CLAUDE_PLUGIN_ROOT}/templates/first-principles-rigor.md`):
1. **DELETION**: What is the minimum true thing about this intuition? Strip ornament.
2. **PRESENCE**: Go to what exists. Read source code, not descriptions. Read papers, not summaries.
3. **URGENCY**: Fastest path to a crisp statement. Don't over-research — crystallize.

**Research Scaffold** (`${CLAUDE_PLUGIN_ROOT}/templates/research-scaffold.md`):
→ `gh search repos` → DeepWiki on best candidates → alphaxiv (3 tools parallel) → WebSearch for practitioner experience.
Landscape the idea space BEFORE engaging the user.

**Deliberation Protocol** (`${CLAUDE_PLUGIN_ROOT}/templates/deliberation-protocol.md`):
The synthesis phase is multi-model. Codex + Gemini + Claude debate what the real problem/opportunity is.

**Context Discipline** (`${CLAUDE_PLUGIN_ROOT}/templates/context-discipline.md`):
Landscaping = sub-agents. Synthesis = /collab. Elicitation = yourself.

## Principles

1. **Research before asking.** Arrive with understanding. The user's first experience is "here's what I found" not "what do you mean?"
2. **Maieutics over informing.** Present your hypothesis of what they want. Let them correct. The correction IS the signal.
3. **Crystallize, don't design.** Output is a single dense statement, not a design doc. Design is /interview's job.
4. **Route explicitly.** The output tells the user: this is a BUILD (→ /interview) or a RESEARCH (→ /research) or BOTH (→ sequence).
5. **Kill weak ideas early.** If the landscape shows the idea is solved, derivative, or intractable — say so. Don't validate everything.

## PHASE 1: LANDSCAPE (autonomous, no user interaction)

Run 4-5 sub-agents in parallel. The user gave you a vague idea — map everything around it.

**Sub-agent 1: What exists?**
`gh search repos` + `gh search code` for implementations, tools, frameworks related to the idea. Return: top 5 candidates with one-line assessment (solved? partial? different approach?).

**Sub-agent 2: What does the field know?**
alphaxiv — all 3 search tools in parallel. Return: key papers, dominant approaches, open problems, where the field disagrees.

**Sub-agent 3: What's the codebase doing?**
Grep/Glob the current project for related functionality. Return: what's already built, what patterns exist, what's adjacent.

**Sub-agent 4: What do practitioners say?**
WebSearch for practitioner experience, blog posts, conference talks, failure stories. Return: what works in practice vs theory, common pitfalls, unmet needs.

**Sub-agent 5 (if the idea involves a specific repo/tool):**
DeepWiki on the relevant repo. Return: architecture, mechanism, limitations, extensibility.

Synthesize all findings into a **Landscape Brief** (internal, not shown to user yet):
```
## Landscape Brief
- What exists: [top solutions, coverage level]
- State of art: [dominant approach, open frontier]
- Our codebase: [what we already have, gaps]
- Practitioner signal: [what works, what fails, unmet needs]
- Opportunity: [what's NOT solved, what's novel, where we'd add value]
```

## PHASE 2: SYNTHESIZE (multi-model deliberation)

Run the Deliberation Protocol on the Landscape Brief:

**Codex**: "Given this landscape, what is the REAL problem the user is trying to solve? Not what they said — what they MEAN. What would they build if they had perfect information?"

**Gemini**: "Contrarian check: is this worth doing? What's the strongest argument AGAINST pursuing this? Is there a simpler version that captures 80% of the value?"

**Claude sub-agent**: "Synthesis: given the landscape + Codex's read + Gemini's critique, what's the precise, crystallized version of this idea? One sentence: 'Build X that does Y because Z' or 'Understand how X works because the field assumes Y but we suspect Z.'"

Iterate until convergence (all 3 agree on the crystallized statement). Max 2 rounds — this is brainstorming, not research.

## PHASE 3: ELICIT (maieutic — present, don't ask)

Now engage the user. Present, in this order:

1. **Your hypothesis**: "Based on what I found, I think you want: [crystallized statement]"
2. **The landscape**: 3-5 bullets of what exists and where the gap is
3. **The contrarian view**: what Gemini's strongest objection was and why you agree or disagree
4. **The route**: "This is a BUILD / RESEARCH / BOTH because..."

Then: **"Am I reading you right, or is the intent different?"**

When the user corrects:
- If the correction reveals something you didn't research → research it immediately (sub-agent), update landscape, re-present
- If the correction sharpens the intent → update the crystallized statement, confirm
- If the correction changes direction entirely → go back to Phase 1 with the new direction

Repeat until the user confirms: "yes, that's it."

## PHASE 4: OUTPUT + ROUTE

Write the crystallized intent to a file and route:

### If BUILD:
```markdown
# Intent: {title}
**Crystallized**: {one-sentence statement}
**Landscape**: {3-5 key findings from Phase 1}
**Why build**: {the gap, the opportunity, what's novel}
**Why NOT build**: {strongest objection, and why we're proceeding anyway}
**Approach signal**: {what to scaffold from, what to build fresh}
```
Write to `docs/intents/YYYY-MM-DD-{slug}.md`
Then: "Intent crystallized. Run `/interview {intent statement}` to produce the execution contract."

### If RESEARCH:
```markdown
# Question: {title}
**Crystallized**: {one-sentence research question}
**Landscape**: {what the field knows, where it disagrees}
**Why research**: {what's genuinely open, why existing answers are insufficient}
**Weakest assumption**: {the assumption most likely to be wrong}
**Cheapest falsification**: {the fastest way to test the weakest assumption}
```
Write to `docs/intents/YYYY-MM-DD-{slug}.md`
Then: "Research question crystallized. Run `/research {question}` to build understanding."

### If BOTH:
Write both documents. Recommend sequence:
- Research first if foundational understanding is missing
- Build first if the research question only becomes clear through prototyping

## Anti-Reward-Hacking

1. **Don't validate everything.** If the landscape shows the idea is solved → say "this already exists: {link}. Use it." If intractable → say so.
2. **Don't over-research.** This is brainstorming, not /discover. Cap Phase 1 at 10 minutes, Phase 2 at 5 minutes. Crystallize fast, refine later.
3. **Don't design.** The output is an intent statement, not an architecture. Resist the urge to spec.
4. **Correction IS the product.** The most valuable thing is when the user says "no, what I actually mean is..." — that's the signal. Optimize for eliciting corrections.
