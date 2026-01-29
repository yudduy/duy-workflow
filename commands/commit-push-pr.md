---
description: Commit, push, and create PR in one command
argument-hint: "[commit message]"
allowed-tools: Bash(git *), Bash(gh pr *)
---

# /commit-push-pr

Quick inner-loop command for committing, pushing, and creating a PR.

## Context

```!
git status
```

```!
git diff HEAD
```

```!
git branch --show-current
```

```!
git log --oneline -5
```

## Instructions

Based on the context above:

1. **If on main/master**: Create a new branch first
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Stage and commit**:
   - If commit message provided as argument, use it
   - Otherwise, generate a concise message from the diff
   ```bash
   git add -A && git commit -m "message"
   ```

3. **Push to origin**:
   ```bash
   git push -u origin HEAD
   ```

4. **Create PR** (if none exists):
   ```bash
   gh pr create --fill
   ```
   - If PR already exists, just report its URL:
   ```bash
   gh pr view --web 2>/dev/null || gh pr create --fill
   ```

5. **Report result**: Output the PR URL

Execute all steps in a single response using parallel Bash calls where possible.
