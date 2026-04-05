---
description: Commit, push, and create PR — with hygiene audit before anything ships
argument-hint: "[commit message]"
allowed-tools: Bash, Read, Glob, Grep, Agent
---

# /commit-push-pr

Commit, push, and PR — but ONLY after a hygiene subagent audits every file.

## Context

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
git status && echo "---" && git branch --show-current && echo "---" && git log --oneline -5
```

```!
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
git diff --stat HEAD
```

## Step 1: HYGIENE AUDIT (mandatory, before any staging)

Spawn a subagent to audit the repo. This is NOT optional.

```
Agent(subagent_type="code-reviewer", prompt="
  Audit this repo for files that should NOT be committed or PR'd.

  CHECK EVERY FILE in git status (untracked + modified). For each, classify:

  REMOVE (must not be in repo):
  - Scratch/temp files: TODO.md, SCRATCH.md, notes.md, *.tmp
  - Model review dumps: r1-*.md, codex-*.md, *-review.md, *-audit.md
  - Generated artifacts: *.log, *.pyc, __pycache__/, node_modules/, .env
  - API keys, tokens, credentials (even in comments)
  - Large binary files (>1MB)
  - Debug/experiment output that isn't part of the feature

  MOVE (useful but wrong location):
  - Reference docs in repo root → docs/
  - API maps, audit docs → docs/reference/
  - Architecture docs → docs/architecture/

  KEEP (belongs in the PR):
  - Source code, tests, config, README, CLAUDE.md
  - Package manifests (package.json, pyproject.toml, etc.)
  - CI/CD configs

  Also check .gitignore — ensure standard ignores exist (node_modules, .env, *.log, __pycache__).

  Output a concrete action list:
  - Files to DELETE (git rm or rm)
  - Files to MOVE (git mv)
  - Lines to add to .gitignore
  - Any secrets or sensitive data found (CRITICAL — block the PR)
")
```

**Execute every action the subagent recommends.** Delete scratch files, move misplaced docs, update .gitignore. Then re-check with `git status`.

## Step 2: Stage selectively (NEVER git add -A)

Review `git status` output. Stage files by name or by directory:
```bash
# CORRECT: stage specific files/dirs
git add src/ tests/ package.json README.md docs/

# WRONG: stage everything blindly
git add -A  # ← NEVER DO THIS
```

If unsure about a file, `git diff <file>` to inspect before staging.

## Step 3: Commit

- If commit message provided as argument, use it
- Otherwise, generate from the diff: `<type>: <description>`
- Review staged changes one final time: `git diff --cached --stat`

```bash
git commit -m "message"
```

## Step 4: Push

```bash
git push -u origin HEAD
```

## Step 5: Create PR

```bash
# Check if PR exists first
gh pr view 2>/dev/null && echo "PR exists" || gh pr create --title "title" --body "$(cat <<'EOF'
## Summary
- bullet points

## Test plan
- [ ] Tests pass
- [ ] No scratch files committed
- [ ] No secrets in diff

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Step 6: Report

Output the PR URL + summary of hygiene actions taken (files removed/moved/ignored).
