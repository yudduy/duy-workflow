# Research Scaffold: Find → Understand → Copy → Adapt

Before writing ANY new code, feature, or system — exhaust what exists. This is not optional. This is the primary engineering act. Building from scratch when a reference exists is reward-hacking.

## The Pipeline (run ALL steps before writing a single line)

### 1. FIND — What already exists?

```bash
# GitHub repos (SOTA implementations)
gh search repos "<keywords>" --limit 10 --json fullName,description,stargazersCount --sort stars
gh search code "<specific patterns>" --limit 10 --json repository,path

# Web (practitioner solutions, blog posts, Stack Overflow)
WebSearch: "{feature} implementation", "{problem} solution github"
```

If something solves 80%+ of the problem → adopt it. Don't reinvent.

### 2. UNDERSTAND — Read the SOURCE, not the README

```
# DeepWiki on the best candidate repos
mcp__deepwiki__ask_question: "How does {repo} implement {feature}?
Show me the key functions, data structures, and control flow."

# For academic grounding (run ALL THREE in parallel)
alphaxiv: embedding_similarity_search + full_text_papers_search + agentic_paper_retrieval
Then: get_paper_content on top hits. answer_pdf_queries to compare.
```

**CRITICAL**: alphaxiv fabricates specific mechanisms. Verify claimed methods against actual paper text via WebFetch.

### 3. COPY — Clone and extract

```bash
# Clone significant repos
git clone --depth 1 {repo_url} /tmp/{repo_name}

# Or read specific files via DeepWiki/GitHub
read_files_from_github_repository: read the actual implementation files
```

Copy the relevant code into your project. The starting point is THEIR code, not your imagination.

### 4. ADAPT — Modify the copied code to fit

The diff between reference and your version should be small and explainable. If you're rewriting more than 30% of the copied code, you either picked the wrong reference or you're drifting.

**Document for every feature:**
```
- Source: {repo/file the code was copied from}
- What was copied: {specific functions/classes}
- What was adapted: {specific changes and why}
- Built from scratch: {NOTHING — or justify why no reference exists}
```

## When "Built from scratch" appears

If no reference exists, a DIFFERENT model must independently confirm this:
```bash
codex exec --skip-git-repo-check "The agent claims no existing implementation exists for: {feature}.
Search GitHub, your knowledge, and DeepWiki. Is this true? If you find a reference, state the repo and file path."
```

## The Golden Rule

If you find yourself typing a class or function from scratch when a reference exists, you are reward-hacking. Stop. Copy. Adapt.

## Verification

After adapting, verify the copied code actually works:
- Run the reference's own tests (if available)
- Run your tests against the adapted version
- Compare behavior: does your version match the reference on the same inputs?
