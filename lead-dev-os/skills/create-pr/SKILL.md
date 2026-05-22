---
name: create-pr
description: Create a GitHub Pull Request on the current branch with a clear, WHAT-focused description and a tasteful emoji in the title. Use this skill whenever the user asks to create a PR, open a pull request, submit a merge request, send changes for code review, or ship a branch — even if they don't explicitly say "PR". Triggers on phrases like "open a PR", "create PR", "make a pull request", "submit for review", "send this for review", "push this up for review", "PR this", or "merge request".
allowed-tools: Bash, Read
---

# Create PR

Open a GitHub Pull Request for the current branch with a description that tells reviewers **what changed** and **why it matters**, not how the code works (reviewers can read the diff). Title gets a single emoji prefix that signals the change type at a glance.

## When this skill should run

The user wants the current branch turned into a reviewable PR. Common phrasings: "open a PR", "create a pull request", "submit for review", "PR this branch", "send this up for review", "make a merge request". If the user is mid-task and the branch isn't ready (no commits beyond the base, dirty working tree they haven't acknowledged), surface that before opening anything — a half-baked PR is worse than no PR.

## Workflow

The skill runs in four phases. Don't skip phases — each one prevents a class of mistake.

### Phase 1 — Gather context (always in parallel)

Run these in a single batched Bash call to minimize round-trips:

- `git status` — confirm working tree state (without `-uall`, large repos)
- `git branch --show-current` — current branch name
- `git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo NO_UPSTREAM` — does the branch track a remote?
- `git remote get-url origin` — confirm a GitHub remote exists
- Determine the base branch: try `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` first; fall back to `main` then `master`.
- `git log <base>..HEAD --oneline` — all commits on this branch
- `git diff <base>...HEAD --stat` — files changed and shape of the change
- `git diff <base>...HEAD` — the actual diff (this is what you'll summarize)

Stop and report to the user if any of the following:

- Not in a git repo → tell them; do nothing else.
- No `gh` CLI available → tell them to install it (`brew install gh`) or run `gh auth login`.
- Current branch is the base branch (e.g., on `main`) → ask them which branch they meant.
- Zero commits ahead of base → there is nothing to PR; surface it.
- Uncommitted changes exist → ask whether to commit them first or proceed without them. Don't silently stash or commit on the user's behalf.

### Phase 2 — Draft the title and body

Read the **full diff** (not just commit messages — commit messages often lie or under-describe). Write the title and body from what the code actually does.

**Title format** — `<emoji> <imperative summary>`, under 70 characters, no trailing period.

Pick the emoji from the dominant change type:

| Emoji | Change type | When to use |
|-------|-------------|-------------|
| ✨ | feat | New user-visible feature or capability |
| 🐛 | fix | Bug fix |
| ♻️ | refactor | Internal restructure, no behavior change |
| 📝 | docs | Documentation only |
| ✅ | test | Tests only (or test infra) |
| 🔧 | chore | Config, tooling, deps, CI |
| ⚡ | perf | Performance improvement |
| 🎨 | style | Formatting, lint, UI polish |
| 🔥 | remove | Deleting code or features |
| 🚧 | wip | Explicitly work-in-progress (rare; only if user asks) |

If the change is genuinely mixed, pick the emoji that matches the **biggest** part of the diff. Don't stack multiple emojis.

**Body format** — use this exact template:

```markdown
## Summary
- <bullet describing WHAT changed, user-facing or behavior-level>
- <another bullet — keep these focused on observable change, not implementation>
- <3–5 bullets total; fewer if the change is small>

## Test plan
- [ ] <concrete check a reviewer or CI can do>
- [ ] <another check>
- [ ] <another check>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Writing the Summary bullets** — describe the *effect* of the change, not the mechanism. Compare:

- ❌ "Refactored `getUser()` to use a Map instead of nested loops"
- ✅ "User lookup is now O(1), removing the slow path on `/dashboard`"

- ❌ "Added a new file `validators/email.ts` exporting `validateEmail`"
- ✅ "Email addresses are now validated on signup; invalid formats are rejected with a clear error"

If you can't say what changed without naming an internal function, the bullet is probably too low-level. Zoom out one level.

**Writing the Test plan** — concrete, checkable items. Prefer commands or user-visible behaviors over vague aspirations.

- ✅ "Run `npm test -- auth.spec.ts` — all green"
- ✅ "Sign up with `not-an-email` — sees inline error"
- ❌ "Make sure nothing is broken"

Emojis in the body: only the 🤖 footer. Don't sprinkle emojis through Summary or Test plan bullets — it hurts scannability.

### Phase 3 — Push the branch if needed

If Phase 1 found `NO_UPSTREAM`:

```bash
git push -u origin <branch-name>
```

If the branch has an upstream but is ahead of it, push:

```bash
git push
```

If the push fails (e.g., non-fast-forward), stop and report — do **not** force-push. Ask the user how to proceed.

### Phase 4 — Create the PR

Use `gh pr create` with a HEREDOC for the body so multi-line formatting survives intact:

```bash
gh pr create --title "<emoji> <title>" --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

If the user's repo uses a base other than the default (e.g., a stacked PR going to a feature branch), pass `--base <branch>`. Don't guess — only set this if context makes it clear (e.g., the current branch was created off a non-default branch and that branch exists on the remote).

Report the PR URL to the user as the last line of your response so it's easy to click.

## Things to avoid

- **Don't `--force` push.** Ever, unless the user explicitly asks.
- **Don't `git add -A` or `git add .`** if you end up needing to commit something. Stage specific files.
- **Don't invent test plan items** you didn't verify are real. If you don't know how to test the change, ask the user or leave a single honest bullet ("Manually verify the new `/profile` page renders").
- **Don't write a "Changes" section that lists every file touched.** The diff already shows that. The Summary section should describe *outcomes*.
- **Don't paraphrase commit messages.** Read the diff. Commits often lump unrelated changes or use shorthand like "fix" that hides what actually happened.
- **Don't open a draft PR** unless the user asked, or unless the branch genuinely is WIP (e.g., placeholder commits, TODOs in the diff that the user flagged).

## Examples

### Example 1 — Feature

Branch has 3 commits adding a CSV export to the reports page.

```
Title: ✨ Add CSV export to reports page

## Summary
- Reports page now has a "Download CSV" button next to the date filter
- Exported file includes all currently-filtered rows, not the full dataset
- Column order matches the on-screen table; timestamps are ISO 8601

## Test plan
- [ ] Filter reports to last 7 days, click Download CSV — file matches table
- [ ] Export with zero results — file has headers only, no rows
- [ ] Export with 10k+ rows — completes without timeout

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Example 2 — Bug fix

Single-commit branch fixing a date-parsing bug.

```
Title: 🐛 Fix timezone offset on event timestamps

## Summary
- Events created in non-UTC timezones no longer show up an hour off
- Backfilled the parser to handle both `Z` and `+00:00` suffixes

## Test plan
- [ ] Create an event at 9:00 AM local — list view shows 9:00 AM
- [ ] Existing events with `+00:00` timestamps still render correctly

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Example 3 — Refactor

```
Title: ♻️ Extract auth middleware into shared module

## Summary
- Auth checks consolidated into `lib/auth/middleware.ts`; behavior unchanged
- All three API entrypoints now import from the shared module

## Test plan
- [ ] Existing auth tests pass: `npm test -- auth`
- [ ] Sign in / sign out flow works end-to-end
- [ ] Protected route returns 401 when unauthenticated

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
