# How to create or modify a concept file

This guide is the canonical authoring reference for files under `concepts/`. Use it whenever you create a new concept or substantially edit an existing one.

For the directory layout and the existing concept index, see [README.md](README.md).

---

## Before you start: do you need a new file?

A new file is justified when **all** of these are true:

- The topic has its own load-when triggers (you can name distinct tasks where this file should be loaded and other existing files should not).
- It will be at least ~50 lines of substantive prose. Smaller than that, fold it into an existing file.
- It does not fit cleanly inside an existing concept (search the [Concept Index](README.md#concept-index) before adding).

Otherwise, add a section to an existing file.

If your topic spans many concepts and is mostly cross-references, consider whether it really belongs as a one-off design doc (e.g. under `lead-dev-os/specs/`) or as a new entry in the README's [Load-When Cheatsheet](README.md#load-when-cheatsheet) instead of a new concept file.

---

## Step-by-step: creating a new concept file

### 1. Pick the folder

```
concepts/
├── domains/<domain>/      # business-logic concepts (cross-source)
├── source/<app>/          # stack-specific concepts (single source app)
└── shared/                # genuine platform-wide concerns
```

**Decision tree:**

1. Does the concept describe a **business domain** (auth, billing, video pipeline, social publishing, etc.) that touches multiple source apps? → `domains/<domain>/`
2. Does it document **code or conventions specific to one source app** (Rails patterns, Python testing, CDK constructs)? → `source/<app>/`
3. Does it document a system that **every source app participates in** (platform overview, the shared DB layer, the cross-stack test stack)? → `shared/`

Maximum nesting is 2 levels under `concepts/`. Don't create a third level.

### 2. Pick the basename

- Lowercase, hyphen-separated.
- Match an existing prefix when adding a sibling: `social-media-*`, `frontend-*`, `chatbot-*`, `api-*`.
- Don't include the folder name in the basename (`auth/auth.md`, not `auth/auth-domain.md`).
- The slug is what other concepts will reference in their `related:` array — pick something stable.

### 3. Write the frontmatter

Copy this template and fill it in. Field-by-field semantics are in the [Frontmatter Reference](#frontmatter-reference) below.

```yaml
---
title: "..."
source_app: [...]
domain: <one-of>
scope: [...]
related: [...]
load_when:
  - "..."
status: current
last_reviewed: YYYY-MM-DD
---
```

Notes:
- `title` is **always double-quoted** — even when it has no special chars. Consistency.
- `last_reviewed` is the date you finalize this file (today, in `YYYY-MM-DD`).
- Valid values for `source_app` and `domain` are project-specific; see the [README's Concept Index](README.md#concept-index) for the current vocabulary. New values require running `/lead-dev-os:create-or-update-concepts` to extend the enum explicitly.

### 4. Write the body

Rules:

- **Do** describe behaviors, contracts, and invariants in prose.
- **Do** link to source files: `[\`path/to/source.rb\`](../../../path/to/source.rb)`.
- **Do** include `Good` / `Bad` pattern examples — small code snippets that *teach a pattern* are different from copying source.
- **Do** include wire-format examples (request/response JSON, SSE events, error envelopes) — those *are* the contract, not implementation.
- **Don't** reproduce a class body, function body, route table, or factory verbatim. If you find yourself pasting from a source file, replace with a `**Source:**` link and a one-paragraph behavior summary.
- **Don't** copy text from another concept file. Cross-link instead.

H1 must match `title` (without the quotes). Start the body with one sentence stating what the concept covers.

### 5. Cross-link

- Markdown links between concept files use **relative paths** from the file's location:
  - Same folder → `(other-file.md)`
  - Sibling folder under `domains/` → `(../other-folder/other-file.md)`
  - Across the tree, from `domains/X/` to `source/Y/` → `(../../source/Y/other-file.md)`
- For source-code references, use enough `../` to escape `concepts/<folder>/<file>.md` to repo root. Files at depth 2 (`shared/X.md`) need 3 `../`; files at depth 3 (`domains/X/Y.md` or `source/X/Y.md`) need 4 `../`.
- Frontmatter `related:` should list **basenames only** (`twelve-labs-integration`, not full paths). Path resolution is by basename.

### 6. Update the index

1. Add an entry under the right group in [`README.md`'s Concept Index](README.md#concept-index).
2. If the concept introduces a new task type, add a row to the [Load-When Cheatsheet](README.md#load-when-cheatsheet).
3. Update `agents-context/AGENTS.md` only if the concept is in the "essential reading" tier (architecture / models / auth) — otherwise the README index is sufficient.

### 7. Update related concepts

- Add this new file's basename to the `related:` array of every concept it cross-references.
- If your file replaces or supersedes part of an existing concept, edit that concept to point at yours.

### 8. Verify

```bash
# from repo root — confirm no broken links
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

Should print `broken: 0`.

---

## Modifying an existing concept

1. Make your edits.
2. **Bump `last_reviewed`** in the frontmatter to today's date.
3. If you add or remove a section, update the file's `load_when` triggers if the answer to "should this file be loaded for task X?" changed.
4. If you change a section that's referenced by other concepts (search for anchor-link patterns of the form `(path-to-file.md#anchor)`), update those references — anchors are case-sensitive and derived from the heading text.
5. If you remove duplicated source code you find in the file, log a one-line note in the commit message; that's a quality improvement worth surfacing.
6. Same rule on cross-links — never leave a dangling markdown link after a rename.

---

## Frontmatter Reference

Every field is required unless explicitly noted as optional.

### `title` (string, quoted)

Human-readable title. **Always double-quoted** for consistency. Matches the file's H1.

```yaml
title: "Twelve Labs Integration"
title: "Social Media: YouTube Data API Publishing"   # quoting handles the colon
```

### `source_app` (array)

Which source application(s) this concept documents. Array even when there is only one entry.

Valid values are project-specific — see the [README's Concept Index](README.md#concept-index) for the current set. Typical examples: `active_snap`, `chatbot`, `infra`.

Use **multiple values** when the concept genuinely spans apps (e.g. a shared DB layer touched by both backend and chatbot). Use **a single value** when one app owns the surface and other apps merely *interact with* it.

### `domain` (single string)

The single best-fit business-logic domain. Pick exactly one. Used for filtering and to tell agents what kind of work this file informs.

Valid values are project-specific — see the [README's Concept Index](README.md#concept-index) section headings for the current domain set. Typical examples: `auth`, `billing`, `data`, `jobs`, `infra`, `frontend-platform`, `api-platform`.

### `scope` (array)

Which implementation surfaces this concept covers. Multi-valued.

Valid values: `backend`, `frontend`, `jobs`, `webhooks`, `testing`, `infra`, `overview`.

Use this to answer "if I'm working on the backend only, which files matter to me?".

### `related` (array of basenames)

Other concept files that cross-reference this one. Basenames only — no path, no `.md` extension.

```yaml
related: [models, background-jobs, websockets, dynamodb]
```

This is the structured equivalent of the prose "Related concepts" section at the bottom of the file. Keep them in sync.

### `load_when` (array of plain-language tasks)

Plain-language descriptions of tasks where this file should be loaded into context. Each item is a complete phrase. Keep to 2–5 entries — these are *triggers*, not a comprehensive reading list.

Style: action-oriented, no fluff.

```yaml
load_when:
  - Adding or modifying a Shoryuken worker
  - Choosing the right queue / priority / FIFO group
  - Debugging job retries, idempotency, or DLQs
```

Avoid:
- Vague triggers like "Working with the system" (everything is "working with the system").
- Triggers that overlap heavily with another file (decide which file owns the trigger).

### `status` (single string)

| Value | Meaning |
|---|---|
| `current` | Up-to-date, safe to load and follow. The default. |
| `draft` | In-progress; may be inaccurate. Loaders should treat as advisory. |
| `deprecated` | Kept for historical context only. Do not follow as-is. Should link to its replacement. |

Most files are `current`. Only mark `deprecated` when a file describes an architecture or pattern that's been removed and you're keeping it as a record.

### `last_reviewed` (ISO date)

`YYYY-MM-DD`. The date the file was last verified against the codebase. Bump on every meaningful edit. Stale dates are a signal to re-audit.

### Optional: `notes`

Free-text caveat or status note that doesn't fit the structured fields. Use sparingly; usually a TODO comment in the body is better.

```yaml
notes: Largest concept file (~70KB). Candidate for splitting into api-conventions, api-webhooks, api-errors.
```

---

## How agents use frontmatter

Frontmatter is the **structured query layer**; the README index + Load-When Cheatsheet is the **primary discovery surface**. Both should agree.

Typical agent workflows:

1. **First load** — read `agents-context/README.md` to learn the index and Load-When Cheatsheet.
2. **Targeted load** — load specific files named by the cheatsheet for the user's task.
3. **Discover by tag** when the cheatsheet doesn't have a row:
   ```bash
   # all concepts in a specific domain
   grep -lE '^domain: <domain>$' agents-context/concepts/**/*.md

   # all concepts touching a specific app
   grep -l "<app>" agents-context/concepts/**/*.md | xargs grep -l "source_app:.*<app>"
   ```
4. **Audit freshness** — `last_reviewed` older than 90 days near a code change should trigger a re-read.
5. **Follow `related:` and the body's links** to expand context only as needed.

Agents should **not** load every file under a folder. Use the cheatsheet + `load_when` to be selective. The whole point of this directory is composable, partial loading.

---

## Common mistakes

- **Reproducing source code.** The single most common violation. If your section has a 30-line block that reads like a class body, replace it with a one-line `**Source:** [\`path\`](...)` link and a paragraph describing behavior.
- **Mismatched frontmatter and body.** `related:` lists `models` but the prose never mentions models. Keep them in sync.
- **Vague `load_when`.** "When working on the chatbot" is too broad. Name the specific task.
- **Forgetting to bump `last_reviewed`** after substantial edits.
- **Adding to the wrong folder** because a topic *touches* multiple sources. Use `source_app: [a, b]` to express that — the file still has a primary owner.
- **Creating a new file when a section in an existing file would do.** When in doubt, add a section.
- **Forgetting the README index.** A file that isn't in the index is invisible to agents loading by cheatsheet.
- **Inventing a new `domain` or `source_app` value.** Run `/lead-dev-os:create-or-update-concepts` to extend the enum explicitly — silent drift defeats the closed-vocabulary contract.
