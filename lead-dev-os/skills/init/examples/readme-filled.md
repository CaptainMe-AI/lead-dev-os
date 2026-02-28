# Active Snap AI Context

This directory contains modular knowledge files that document Active Snap AI's concepts, architecture, and design principles. These files are designed to be:

- **Composable** - Load only what you need
- **Self-referencing** - Concepts link to related concepts
- **Version-controlled** - Track evolution of ideas over time
- **AI-friendly** - Agents can load specific concepts as context

## Available Concepts

### Core Concepts

- **[architecture.md](concepts/architecture.md)** - System design, tech stack, data flow, service layer patterns
- **[models.md](concepts/models.md)** - Data models (User, Organization, Video, Project, SocialMediaAccount), relationships, factories
- **[auth.md](concepts/auth.md)** - Authentication (Devise, JWT, OAuth) and authorization (Pundit policies)

### Domain Concepts

- **[api.md](concepts/api.md)** - REST API structure, endpoints, request/response formats, error handling
- **[frontend.md](concepts/frontend.md)** - React architecture overview, technology stack, directory structure, routing
  - **[frontend-styling.md](concepts/frontend-styling.md)** - Typography, Tailwind config, design tokens, gradients, common patterns
  - **[frontend-components.md](concepts/frontend-components.md)** - Component patterns, shared components, Layout, UI primitives
  - **[frontend-features.md](concepts/frontend-features.md)** - Videos, Brands, Settings feature implementations
  - **[frontend-api.md](concepts/frontend-api.md)** - API services, hooks, TypeScript types, AuthContext
- **[video-editing.md](concepts/video-editing.md)** - Remotion-based video editor (v1.1.0 upstream), timeline, layers, state management, extension patterns, CLAUDE.md references
- **[storage.md](concepts/storage.md)** - AWS S3 video storage, presigned URL generation, upload flow
- **[social-media.md](concepts/social-media.md)** - OAuth integrations for Instagram, YouTube, TikTok, token refresh
- **[social-media-posting.md](concepts/social-media-posting.md)** - Publishing architecture, data flow, status lifecycle, publisher services, WebSocket broadcasts
  - **[social-media-youtube.md](concepts/social-media-youtube.md)** - YouTube Data API upload flow, Shorts, chapters, scheduling, quota
  - **[social-media-instagram.md](concepts/social-media-instagram.md)** - Meta Graph API container publishing, Reels/Stories/FeedVideo, rate limits
  - **[social-media-facebook.md](concepts/social-media-facebook.md)** - Facebook Pages Video API, Reels multi-phase upload, scheduling
  - **[social-media-tiktok.md](concepts/social-media-tiktok.md)** - TikTok Content Posting API, chunked upload, privacy levels
- **[testing.md](concepts/testing.md)** - RSpec, Cypress, FactoryBot, linting configuration
- **[infrastructure.md](concepts/infrastructure.md)** - AWS CDK stack, Docker, CI/CD deployment
- **[cdk-testing.md](concepts/cdk-testing.md)** - CDK test patterns, nested stack testing, assertion conventions
- **[chatbot.md](concepts/chatbot.md)** - Chatbot service: Python/FastAPI, LangChain + LangGraph, development workflow, testing, Docker
- **[background-jobs.md](concepts/background-jobs.md)** - Shoryuken workers, AWS SQS FIFO queues, job priority patterns
- **[websockets.md](concepts/websockets.md)** - ActionCable with SolidCable, real-time video status updates, channel patterns

## Development Standards

Each concept file links to relevant standards in `agents-context/standards/`. These standards define best practices that must be followed:

| Category | Standards |
|----------|-----------|
| **Backend** | [api.md](standards/backend/api.md), [models.md](standards/backend/models.md), [migrations.md](standards/backend/migrations.md), [queries.md](standards/backend/queries.md) |
| **Frontend** | [components.md](standards/frontend/components.md), [css.md](standards/frontend/css.md), [responsive.md](standards/frontend/responsive.md), [accessibility.md](standards/frontend/accessibility.md) |
| **Global** | [coding-style.md](standards/global/coding-style.md), [commenting.md](standards/global/commenting.md), [conventions.md](standards/global/conventions.md), [error-handling.md](standards/global/error-handling.md), [validation.md](standards/global/validation.md) |
| **Testing** | [test-writing.md](standards/testing/test-writing.md) |

## Using Context Files

### For Developers

Read concept files to understand specific aspects of Active Snap AI:

```bash
# Start with core concepts
cat agents-context/concepts/architecture.md

# Then explore specific areas
cat agents-context/concepts/models.md
cat agents-context/concepts/auth.md
```

### For AI Agents

Load relevant concepts based on your task:

- **Adding API endpoint** → `api.md`, `auth.md`
- **Adding UI feature** → `frontend.md`, `frontend-components.md`, `frontend-styling.md`
- **Working with videos** → `models.md`, `storage.md`, `frontend-features.md`
- **Video Studio page** → `frontend-features.md`, `frontend-components.md`
- **Video editor features** → `video-editing.md`, `frontend.md`
- **Adding editor item types** → `video-editing.md`
- **Extending the editor** → `video-editing.md` (see Extension Patterns section)
- **Frontend styling/design** → `frontend-styling.md`
- **API services/hooks** → `frontend-api.md`, `api.md`
- **Social media integration** → `social-media.md`, `auth.md`
- **Social media publishing** → `social-media-posting.md`, `social-media-youtube.md`, `social-media-instagram.md`, `social-media-facebook.md`, `social-media-tiktok.md`
- **Publishing to a specific platform** → The platform-specific doc + `social-media-posting.md`
- **Writing tests** → `testing.md`
- **Testing CDK infrastructure** → `cdk-testing.md`, `infrastructure.md`
- **Working with chatbot** → `chatbot.md`, `infrastructure.md`
- **Deploying changes** → `infrastructure.md`
- **Background processing** → `background-jobs.md`
- **Real-time updates** → `websockets.md`, `background-jobs.md`

Task groups generated by `/lead-dev-os:step2-scope-tasks` automatically include **"Read before starting"** directives that list exactly which concept and standard files to load.

## Contributing

When adding new concepts:

1. Create focused, single-topic files (prefer smaller over larger)
2. Use wiki-style links to reference related concepts: `[[concept-name]]`
3. Include a "Related:" section at the top
4. Add an entry to this README under the appropriate section
5. Update cross-references in existing concepts
6. Update AGENTS.md Context Documentation Index
7. Adding code samples:
   7.1. yes: best practices
   7.2. yes: generalized patterns
   7.3. no: code that exists in source files — reference the source file path instead

When modifying existing concepts:

1. Update relevant sections
2. Update cross-references in related concepts
3. Update this README if the scope of the concept changed
4. Adding code samples:
   4.1. yes: best practices
   4.2. yes: generalized patterns
   4.3. no: code that exists in source files — reference the source file path instead

## Philosophy

> "Context engineering isn't about prompt templates — it's about managing modular knowledge as first-class composable primitives."

These concept files allow agents to fetch only the knowledge they need, keeping context windows efficient while maintaining comprehensive project documentation.
