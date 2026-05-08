# Migration: flat layout → bucketed layout

This reference is loaded by `create-or-update-concepts/SKILL.md` only when migration is needed (Phase 1 detects flat-layout artifacts). If you reached this file outside that flow, you probably shouldn't be running these steps.

## Detection

Run these three checks during Phase 1:

```bash
# 1. Flat concept files (any .md directly under concepts/, not in a bucket)
ls agents-context/concepts/*.md 2>/dev/null

# 2. Missing authoring guide
[ ! -f agents-context/HOW_TO_CREATE_A_CONCEPT.md ] && echo "missing"

# 3. Concept files without YAML frontmatter
for f in agents-context/concepts/**/*.md; do
  head -1 "$f" | grep -q '^---$' || echo "no-frontmatter: $f"
done
```

If any return positive results, you're working on a project configured before the bucketed layout was introduced. Announce migration mode to the user up-front:

> *"Detected a pre-bucketed layout — N flat concept file(s), missing HOW_TO_CREATE_A_CONCEPT.md, M files without frontmatter. I'll propose moves into `domains/`, `source/`, `shared/` as part of the coverage map, and back-fill frontmatter. Existing cross-links and the README index will be rewritten."*

For each flat file, read it and provisionally classify it under the folder decision tree (Phase 3, Gate 2). These provisional placements feed the coverage map.

## Lay down HOW_TO_CREATE_A_CONCEPT.md if missing

The plugin ships the canonical template at `<plugin-root>/skills/configure-project/templates/how-to-create-a-concept.md`. Resolve `<plugin-root>` in this order — stop at the first one that succeeds:

**1. Try `${CLAUDE_PLUGIN_ROOT}`.** Claude Code sets this env var for marketplace-installed plugins:

```bash
TEMPLATE="${CLAUDE_PLUGIN_ROOT:-}/skills/configure-project/templates/how-to-create-a-concept.md"
[[ -n "${CLAUDE_PLUGIN_ROOT:-}" && -f "$TEMPLATE" ]] && \
  cp "$TEMPLATE" agents-context/HOW_TO_CREATE_A_CONCEPT.md
```

**2. Try common dev paths.** When the user runs `claude --plugin-dir <path>`, `CLAUDE_PLUGIN_ROOT` is often unset. Probe likely checkout locations:

```bash
for guess in \
  "$HOME/lead-dev-os/lead-dev-os" \
  "$HOME/development/lead-dev-os/lead-dev-os" \
  "$HOME/dev/lead-dev-os/lead-dev-os" \
  "$HOME/.claude/plugins/lead-dev-os/lead-dev-os" \
  "$HOME/.claude/plugins/cache/lead-dev-os"; do
  candidate="$guess/skills/configure-project/templates/how-to-create-a-concept.md"
  [[ -f "$candidate" ]] && { cp "$candidate" agents-context/HOW_TO_CREATE_A_CONCEPT.md; break; }
done
```

**3. Ask the user.** If neither of the above finds the file, prompt:

> *"I couldn't auto-resolve the lead-dev-os plugin path. Paste the absolute path to your plugin checkout (the directory containing `.claude-plugin/plugin.json`) and I'll copy the template. Example: `/Users/you/development/lead-dev-os/lead-dev-os`"*

Then use that path:

```bash
cp "$USER_PROVIDED_PATH/skills/configure-project/templates/how-to-create-a-concept.md" \
   agents-context/HOW_TO_CREATE_A_CONCEPT.md
```

**4. Last resort.** If the user doesn't have the plugin checked out locally (rare), tell them to re-run `/lead-dev-os:configure-project` once the plugin is reachable. It will skip existing files and only add `HOW_TO_CREATE_A_CONCEPT.md`.

After copying, confirm the file is in place: `ls agents-context/HOW_TO_CREATE_A_CONCEPT.md`.

## Coverage map: include MOVE rows

When building the coverage map (Phase 3, Gate 2), include one MOVE row per existing flat file:

```
| Area / Topic              | Folder placement     | Existing concept           | Proposed action                                       |
|---------------------------|----------------------|----------------------------|-------------------------------------------------------|
| (migration) auth.md       | domains/auth/        | concepts/auth.md (flat)    | MOVE → domains/auth/auth.md + back-fill frontmatter   |
| (migration) testing.md    | shared/              | concepts/testing.md (flat) | MOVE → shared/testing.md + back-fill frontmatter      |
```

The user reviews and approves each move target before any file is touched.

## Per-file migration steps

For each MOVE row, run the steps in this exact order so cross-links stay valid throughout:

### 1. Move the file

Prefer `git mv` so history follows the rename:

```bash
git mv agents-context/concepts/<file>.md agents-context/concepts/<bucket>/<file>.md
```

If the project isn't a git repo, plain `mv` is fine. Process moves one at a time, not in a batch — the link-rewrite step needs to know the file's new location before it can compute new relative paths.

### 2. Back-fill frontmatter

If the file lacks a `---` block at the top, add one using the rules from `agents-context/HOW_TO_CREATE_A_CONCEPT.md`. Derive:

- `title` from the existing H1 (wrap in double quotes).
- `source_app` and `domain` from the file's content + the approved enum (use the same classification you used to choose the bucket).
- `scope` from which surfaces the file describes (`backend | frontend | jobs | webhooks | testing | infra | overview`).
- `load_when` (2–5 entries) from the tasks the file would actually inform — read the body and ask "for what task would I want this file open?".
- `related` from existing inline links and `## Related` (or similar) sections.
- `last_reviewed: {today}`, `status: current`.

Tell the user when you're back-filling so they can review the inferred fields.

### 3. Rewrite cross-links inside the moved file

Existing relative links now point at the wrong number of `../` levels. Audit every link:

- Convert any `[[wiki-style]]` references to relative markdown links based on the new location.
- Recompute `(relative/path.md)` paths from the file's new folder using the conventions in `HOW_TO_CREATE_A_CONCEPT.md`.
- Source-code references (`(../../source/...)`) need one or two more `../` now that the file lives one or two levels deeper.

### 4. Rewrite back-references in other files

Any other concept file that linked to this one (by old flat path) needs its links updated to the new bucket path. The frontmatter `related:` arrays use **basenames only**, so those don't need to change — only the markdown links in the body do.

### 5. Re-run the link audit

After all moves are complete:

```bash
python3 -c '
import re, pathlib
ROOT = pathlib.Path("agents-context/concepts")
link_re = re.compile(r"\]\(([^)]+\.md)(?:#[^)]*)?\)")
broken = []
for p in ROOT.rglob("*.md"):
    for m in link_re.finditer(p.read_text()):
        link = m.group(1)
        if link.startswith(("http","/")): continue
        if not (p.parent / link).resolve().exists():
            broken.append((str(p), link))
print(f"broken: {len(broken)}"); [print(f"  {f} -> {l}") for f, l in broken[:10]]
'
```

Fix any dangling links before moving on to Phase 5.

## Phase 5 in migration mode

The existing README's Concept Index points at old flat paths. Replace the Concept Index section wholesale with the new bucket-grouped structure — don't try to patch entries individually. Same for the Load-When Cheatsheet if it exists.

## Reporting

In Phase 6, report migration outcomes as a separate "Concepts migrated" section: each MOVE (`concepts/auth.md → concepts/domains/auth/auth.md`), plus a count of cross-links rewritten and back-references updated.

Migration is best-effort, not magic — review the result with the user and ask about any classification you're unsure of (especially `domain` choices for files that span multiple concerns).
