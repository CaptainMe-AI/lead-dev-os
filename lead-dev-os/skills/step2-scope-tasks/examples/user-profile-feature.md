# Task Breakdown: User Profile Page

> Spec: 2026-02-25-user-profile
> Generated: 2026-02-25
> Status: Pending

## Overview
Total Tasks: 20

## Context Management

### Before Starting Each Task Group
Load relevant concepts from `agents-context/README.md` to understand existing patterns:
- Review the concept files listed in each task group's "Load Concepts" section
- Understand existing patterns before implementing new code

### After Completing Each Task Group
Update relevant concepts in `agents-context/README.md` if applicable:
- Document new fields, endpoints, or component changes added
- Update existing documentation if behavior changed
- Add cross-references to related concepts

## Planning
**Use plan mode per task group when implementing** - This will allow further breakdown of each task into sub-tasks and plan them out.
**When using plan mode, always include a final plan step to return to this tasks.md and check off completed tasks** (per project CLAUDE.md rule).
## Task List

### Data & API Layer

#### Task Group 1: Profile API Endpoints

Expose authenticated endpoints for reading and updating user profile data including display name, bio, and timezone.

**Read before starting:**
- `agents-context/concepts/auth-system.md` — understand authentication middleware and user model
- `agents-context/standards/coding-style.md` — follow naming and file organization conventions
- `agents-context/standards/testing.md` — follow testing conventions for API specs

**Update after completing:**
- `agents-context/concepts/auth-system.md` — if user model is extended with new profile fields
- Create `agents-context/concepts/user-profile.md` — if new patterns for profile data management emerge

**Dependencies:** None

- [ ] 1.0 Complete profile API layer
  - [ ] 1.1 Write 2-8 focused tests for profile API functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical endpoint behaviors (e.g., GET returns profile fields, PATCH updates allowed fields, reject invalid timezone)
    - Skip exhaustive coverage of all validation rules and error scenarios
  - [ ] 1.2 Add profile GET endpoint
    - Returns: display name, email, bio, timezone, avatar URL
    - Auth: requires authenticated user
    - Follow pattern from: `src/api/auth.ts`
  - [ ] 1.3 Add profile PATCH endpoint
    - Updatable fields: display name, bio, timezone
    - Validations: non-empty display name, valid timezone value
  - [ ] 1.4 Ensure API tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- GET endpoint returns all profile fields
- PATCH validates and persists updates
- Proper authentication enforced

### File Upload Layer

#### Task Group 2: Avatar Upload Service

Enable users to upload and store profile avatars with file type and size validation.

**Read before starting:**
- `agents-context/concepts/file-uploads.md` — understand existing S3 upload patterns
- `agents-context/standards/testing.md` — follow testing conventions

**Update after completing:**
- `agents-context/concepts/file-uploads.md` — document avatar-specific upload pattern (validation, size limits)

**Dependencies:** Task Group 1

- [ ] 2.0 Complete avatar upload service
  - [ ] 2.1 Write 2-8 focused tests for avatar upload functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical upload behaviors (e.g., accept valid JPEG/PNG, reject oversized file, presigned URL generation)
    - Skip exhaustive testing of all file types and error paths
  - [ ] 2.2 Extend upload service with avatar validation
    - Accepted types: JPEG, PNG
    - Max size: 5MB
    - Reuse pattern from: `src/services/upload.ts`
  - [ ] 2.3 Add avatar upload endpoint
    - Returns: stored URL for the uploaded avatar
    - Wires into profile PATCH for avatar URL update
  - [ ] 2.4 Ensure upload tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass
- Valid uploads succeed and return URL
- Invalid file types and oversized files are rejected
- Presigned URLs generated correctly

### Frontend Components

#### Task Group 3: Profile Page UI

Build the user-facing profile settings page with view/edit modes and avatar upload support.

**Read before starting:**
- `agents-context/standards/coding-style.md` — follow component naming and file organization
- `agents-context/concepts/auth-system.md` — understand route protection patterns

**Update after completing:**
- Create `agents-context/concepts/user-profile.md` — if new UI patterns for settings pages emerge

**Dependencies:** Task Group 2

- [ ] 3.0 Complete profile page UI
  - [ ] 3.1 Write 2-8 focused tests for profile UI components
    - Limit to 2-8 highly focused tests maximum
    - Test only critical component behaviors (e.g., renders fields with current values, edit mode saves changes, avatar upload shows preview)
    - Skip exhaustive testing of all component states and interactions
  - [ ] 3.2 Create profile page component
    - View/edit modes inside settings shell
    - Fields: display name, email (read-only), bio, timezone
    - Follow pattern from: existing settings pages
  - [ ] 3.3 Create avatar upload component
    - File picker with drag-and-drop
    - Preview before upload
    - Progress indicator
  - [ ] 3.4 Wire up API calls
    - Load profile data on mount
    - Save changes via PATCH
    - Upload avatar via upload endpoint
  - [ ] 3.5 Add error handling and success feedback
    - Inline errors on save failure with form state preservation
    - Success toast on save
    - Mobile responsive layout
  - [ ] 3.6 Ensure UI tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- Profile page renders with current data
- Edit mode saves and reflects changes
- Avatar upload shows preview and persists

### Testing

#### Task Group 4: Test Review & Gap Analysis

Review all profile feature tests and fill critical coverage gaps for end-to-end workflows.

**Read before starting:**
- `agents-context/concepts/auth-system.md` — review auth patterns tested
- `agents-context/concepts/file-uploads.md` — review upload patterns tested
- `agents-context/standards/testing.md` — follow testing conventions

**Update after completing:**
- `agents-context/concepts/user-profile.md` — document final profile page patterns and conventions

**Dependencies:** Task Groups 1-3

- [ ] 4.0 Review existing tests and fill critical gaps only
  - [ ] 4.1 Review tests from Task Groups 1-3
    - Review the 2-8 tests written for profile API (Task 1.1)
    - Review the 2-8 tests written for avatar upload (Task 2.1)
    - Review the 2-8 tests written for profile UI (Task 3.1)
    - Total existing tests: approximately 6-24 tests
  - [ ] 4.2 Analyze test coverage gaps for profile feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to profile feature requirements
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
  - [ ] 4.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on: full profile edit flow (load → edit → save → reload → verify), avatar upload end-to-end
    - Do NOT write comprehensive coverage for all scenarios
    - Skip edge cases, performance tests, and accessibility tests unless business-critical
  - [ ] 4.4 Run feature-specific tests only
    - Run ONLY tests related to the profile feature (tests from 1.1, 2.1, 3.1, and 4.3)
    - Expected total: approximately 16-34 tests maximum
    - Do NOT run the entire application test suite
    - Verify critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 16-34 tests total)
- Critical user workflows for profile feature are covered
- No more than 10 additional tests added when filling gaps
- Testing focused exclusively on profile feature requirements

## Execution Order

Recommended implementation sequence:
1. Data & API Layer (Task Group 1)
2. File Upload Layer (Task Group 2)
3. Frontend Components (Task Group 3)
4. Test Review & Gap Analysis (Task Group 4)
