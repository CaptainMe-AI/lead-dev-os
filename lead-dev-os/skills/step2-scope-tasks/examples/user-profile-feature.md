# Tasks: User Profile Page

> Spec: 2026-02-25-user-profile
> Generated: 2026-02-25
> Status: Pending

## Task Group 1: Data Layer & API

**Read before starting:**
- `agents-context/concepts/auth-system.md` — understand authentication middleware and user model
- `agents-context/standards/coding-style.md` — follow naming and file organization conventions
- `agents-context/standards/testing.md` — follow testing conventions for API specs

**Update after completing:**
- `agents-context/concepts/auth-system.md` — if user model is extended with new profile fields
- Create `agents-context/concepts/user-profile.md` — if new patterns for profile data management emerge

**Depends on:** None
**Modifies:** `src/api/profile.ts`, `src/models/user.ts`, `src/tests/api/profile.test.ts`

- [ ] **Test:** Write API tests for GET `/api/profile` — returns current user profile fields
- [ ] **Test:** Write API tests for PATCH `/api/profile` — updates display name, bio, timezone
- [ ] **Test:** Write validation tests — reject invalid timezone, empty display name
- [ ] **Implement:** Add profile GET endpoint returning display name, email, bio, timezone, avatar URL
- [ ] **Implement:** Add profile PATCH endpoint with field validation
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 2: Avatar Upload Service

**Read before starting:**
- `agents-context/concepts/file-uploads.md` — understand existing S3 upload patterns
- `agents-context/standards/testing.md` — follow testing conventions

**Update after completing:**
- `agents-context/concepts/file-uploads.md` — document avatar-specific upload pattern (validation, size limits)

**Depends on:** Task Group 1
**Modifies:** `src/services/upload.ts`, `src/api/profile.ts`, `src/tests/services/upload.test.ts`

- [ ] **Test:** Write upload tests — accept JPEG/PNG under 5MB, reject other types and oversized files
- [ ] **Test:** Write test for presigned URL generation for avatar uploads
- [ ] **Implement:** Extend upload service with avatar-specific validation (file type, 5MB limit)
- [ ] **Implement:** Add avatar upload endpoint returning the stored URL
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 3: Profile Page UI

**Read before starting:**
- `agents-context/standards/coding-style.md` — follow component naming and file organization
- `agents-context/concepts/auth-system.md` — understand route protection patterns

**Update after completing:**
- Create `agents-context/concepts/user-profile.md` — if new UI patterns for settings pages emerge

**Depends on:** Task Group 2
**Modifies:** `src/pages/settings/profile.tsx`, `src/components/avatar-upload.tsx`, `src/tests/pages/profile.test.tsx`

- [ ] **Test:** Write component test — profile page renders all fields with current values
- [ ] **Test:** Write component test — edit mode allows field changes and save
- [ ] **Test:** Write component test — avatar upload shows preview
- [ ] **Implement:** Create profile page component with view/edit modes inside settings shell
- [ ] **Implement:** Create avatar upload component with file picker and preview
- [ ] **Implement:** Wire up API calls for loading and saving profile data
- [ ] **Verify:** Run tests, confirm all pass

## Task Group 4: Integration & Polish

**Read before starting:**
- `agents-context/standards/coding-style.md` — follow conventions for error handling and UI feedback
- `agents-context/concepts/user-profile.md` — review patterns established in previous groups

**Update after completing:**
- `agents-context/concepts/user-profile.md` — document final profile page patterns and conventions

**Depends on:** Task Group 3
**Modifies:** `src/pages/settings/profile.tsx`, `src/components/avatar-upload.tsx`

- [ ] **Test:** Write E2E test — full profile edit flow (load, edit, save, reload, verify)
- [ ] **Test:** Write test — inline error display on save failure
- [ ] **Implement:** Add inline error handling for save failures with form state preservation
- [ ] **Implement:** Add success toast on successful save
- [ ] **Implement:** Ensure mobile responsive layout
- [ ] **Verify:** Run all tests, confirm all pass. Manual check on mobile viewport.

## Dependency Flow

Group 1 → Group 2 → Group 3 → Group 4

## Completion Criteria

- [ ] All tests pass
- [ ] All success criteria from spec.md are met
- [ ] Code follows standards in `agents-context/standards/`
- [ ] Concept files updated/created for any new patterns established
- [ ] No regressions in existing functionality
