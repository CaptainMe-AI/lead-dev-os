# Spec Requirements: User Profile Page

## Initial Description

> Build a user profile page where users can view and edit their personal information, avatar, and account settings.

## Requirements Discussion

### First Round Questions

**Q1:** What is explicitly in and out of scope for this profile page?
**Answer:** In scope: display name, email, avatar upload, bio, and timezone. Out of scope: password changes (separate flow), billing info, and notification preferences.

**Q2:** How will users navigate to their profile? What's the entry point?
**Answer:** Avatar icon in the top-right nav bar opens a dropdown with "My Profile" link. Direct URL at `/settings/profile`.

**Q3:** What data does the profile feature create, read, update, or delete?
**Answer:** Reads user record from the database. Updates display name, bio, timezone, and avatar. Avatar images are stored in S3. No delete — users can clear fields but not delete their account from here.

**Q4:** What happens with edge cases — empty states, errors, large uploads?
**Answer:** Avatar uploads capped at 5MB, JPEG/PNG only. Show current values as defaults in edit mode. If save fails, show inline error and preserve form state.

**Q5:** Does this touch other features or external services?
**Answer:** Uses the existing auth middleware for authentication. Avatar upload goes to S3 via the existing file upload service. Display name changes should propagate to the activity feed.

**Q6:** How will we know this feature is "done"?
**Answer:** User can view and edit all profile fields. Avatar upload works with preview. Changes persist after page reload. Mobile responsive.

**Q7:** I found these existing patterns that may be relevant: `agents-context/concepts/auth-system.md` references the auth middleware at `src/middleware/auth.ts`, and `agents-context/concepts/file-uploads.md` references the S3 upload service at `src/services/upload.ts`. Should we reuse these?
**Answer:** Yes, reuse both. The upload service already handles S3 presigned URLs — extend it for avatar-specific validation (dimensions, file type).

**Q8:** Do you have any mockups or wireframes? Drop them into `specs/2026-02-25-user-profile/planning/visuals/`.
**Answer:** Added `profile-mockup.png` to the visuals folder.

### Existing Code to Reference

**From Concept Files:**
- Concept: `auth-system.md` — Related source: `src/middleware/auth.ts`
- Relevance: Profile page requires authenticated access; reuse auth middleware

- Concept: `file-uploads.md` — Related source: `src/services/upload.ts`
- Relevance: Avatar upload can extend existing S3 upload service

**From User Input:**
- Feature: Settings layout — Path: `src/pages/settings/`
- Components to potentially reuse: Settings page shell, form components

### Follow-up Questions

**Follow-up 1:** The mockup shows a cropping tool for avatars — is that in scope for v1, or can we use a simple file picker?
**Answer:** Simple file picker for v1. Cropping is a nice-to-have for later.

## Visual Assets

### Files Provided
- `profile-mockup.png`: High-fidelity mockup showing profile view and edit modes side by side

### Visual Insights
- Two-column layout: avatar and key info on the left, form fields on the right
- Edit mode uses inline editing (no separate page)
- Avatar has a hover overlay with "Change" text
- Fidelity level: high-fidelity mockup

## Requirements Summary

### Must Have
- Display and edit: display name, email (read-only), bio, timezone
- Avatar upload with 5MB limit, JPEG/PNG only, with preview
- Authenticated access via existing auth middleware
- Inline error handling on save failure
- Mobile responsive layout

### Should Have
- Avatar hover overlay for change action
- Timezone dropdown with common timezones
- Success toast on save

### Reusability Opportunities
- Auth middleware at `src/middleware/auth.ts`
- S3 upload service at `src/services/upload.ts` — extend for avatar validation
- Settings page shell at `src/pages/settings/`
- Form components from shared UI library

### Out of Scope
- Password changes
- Account deletion
- Billing information
- Notification preferences
- Avatar cropping tool
