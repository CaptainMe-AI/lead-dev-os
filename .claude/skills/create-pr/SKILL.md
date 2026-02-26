---
name: create-pr
description: Creates a GitHub Pull Request on the current branch with a description focused on WHAT changed (not HOW). Uses emojis in the title and description. Use when the user asks to create a PR, open a pull request, or submit changes for review. Triggers on mentions of PR, pull request, merge request, or code review.
---

# Create GitHub Pull Request Skill

## Purpose
This skill creates well-structured GitHub Pull Requests with descriptive titles and bodies that communicate WHAT the changes accomplish from a product/user perspective, not HOW they were implemented. Titles and descriptions use emojis for visual clarity.

## When to Use This Skill

Use this skill when:
- The user asks to create a PR or pull request
- The user wants to submit their current branch for review
- The user says "open a PR", "create a PR", "submit for review"

## Process

### Step 1: Gather Context

Run these commands in parallel to understand the current state:

1. `git status` — check for uncommitted changes
2. `git log --oneline main..HEAD` — see all commits on this branch vs main
3. `git diff main...HEAD --stat` — see file-level summary of all changes
4. `git branch --show-current` — get current branch name

### Step 2: Analyze Changes

1. Run `git diff main...HEAD` to read the full diff
2. Identify the **purpose** of the changes — what does this accomplish for the user/product?
3. Group changes into logical themes (e.g., new feature, UI update, backend change)
4. Do NOT describe implementation details (no mention of specific functions, classes, variable names, or code patterns)

### Step 3: Draft the PR

**Title format:**
```
<emoji> <Short description of WHAT changed>
```

Title rules:
- Under 70 characters
- Start with a relevant emoji (e.g., ✨ new feature, 🐛 bug fix, 🎨 UI change, 🔧 config, 📦 dependency, 🚀 performance, 🔒 security, ♻️ refactor, 🧪 tests, 📝 docs)
- Describe WHAT, not HOW
- Use present tense ("Add dark mode" not "Added dark mode")

**Body format:**
```markdown
## ✨ What's New

- <emoji> <Change description from user/product perspective>
- <emoji> <Change description from user/product perspective>

## 🧪 Test Plan

- [ ] <verification step>
- [ ] <verification step>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Body rules:
- Focus on WHAT changed and WHY it matters
- Use emojis for each bullet point
- Never mention file names, function names, or implementation details in the summary
- The test plan should describe how to verify the behavior, not which test files to run
- Keep bullet points concise (one line each)

### Step 4: Create the PR

1. If there are uncommitted changes, warn the user and ask if they want to commit first
2. Push the branch if it hasn't been pushed: `git push -u origin <branch-name>`
3. Create the PR using `gh pr create`:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body content>
EOF
)"
```

4. Return the PR URL to the user

## Examples

### Good Title
```
✨ Add video preview for generated videos
```

### Bad Title (too implementation-focused)
```
Add GeneratedVideoPreview component and update index controller
```

### Good Description
```markdown
## ✨ What's New

- 🎬 Users can now preview generated videos directly from the video list
- advancement Players auto-pause when the preview modal is closed
- 📱 Preview works across desktop and mobile viewports

## 🧪 Test Plan

- [ ] Open the generated videos page and click a video to preview
- [ ] Verify the video plays in the preview modal
- [ ] Close the modal and confirm playback stops
```

### Bad Description (too implementation-focused)
```markdown
- Added GeneratedVideoPreview React component in app/javascript/components/
- Updated VideosController#index to include video URLs
- Modified routes.rb to add preview endpoint
```
