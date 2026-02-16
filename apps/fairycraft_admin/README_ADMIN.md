# FairyCraft Admin: Phase 0 Recon

## Current state summary (as of 2026-02-16)

- `apps/fairycraft_admin` exists and runs as Flutter app, but is still MVP-level:
  - Single-file implementation in `lib/main.dart`.
  - No route-based web admin shell (tab-based only).
  - Firebase auth supports email/password; mock fallback mode exists.
  - Admin claim (`admin=true`) is checked, but not enforced as a strict gate.
  - Only two data areas: legacy `admin_policy/runtime` and `usage_daily`.
- Routing approach in current admin app:
  - No `go_router` route map yet.
  - No URL routes for `/login`, `/policies`, `/templates`, `/tiers`, `/monitor`, `/test-console`, `/settings`.
- Firebase bootstrap pattern in monorepo:
  - Mobile app (`apps/fairycraft_app`) already uses flavor-aware bootstrap via `--dart-define=FLAVOR=dev|prod`.
  - Admin app currently uses a single placeholder `firebase_options.dart`; no flavor split yet.
  - Repo docs require Firebase native files/options to remain local and not committed.
- `server/story-agent` contract (current):
  - Main endpoints: `/v1/story/create`, `/v1/story/continue`, `/v1/story/illustrate`, plus TTS/STT endpoints.
  - Runtime policy source today is legacy `admin_policy/runtime` only.
  - Audit currently writes `story_audit`; usage writes `usage_daily`.
  - No `/v1/admin/dry-run` endpoint yet.
  - No policy/template/tier resolution using `policies_v1`, `style_templates_v1`, `subscription_tiers_v1`.
  - No writes to `generation_logs_v1` or `test_runs_v1`.

## Implementation plan (sequential)

1. Baseline admin web architecture and routing:
   - Add modular app structure and web-first route shell.
   - Introduce all required routes and navigation.
   - Add admin run/deploy docs and flavor-based environment handling.
2. Auth + strict admin gating:
   - Add Google sign-in flow for web with Firebase Auth.
   - Add `AdminGuard` redirect rules enforcing auth + `admin=true`.
   - Add local-only debug admin UID bootstrap from untracked local file.
3. Firestore domain/data layer:
   - Implement versioned admin schema models with `toJson/fromJson`.
   - Implement repositories for policies/templates/tiers/logs/test-runs/config.
   - Add admin-side effective policy/template resolver.
4. UI pages:
   - Implement dashboard, policies, templates, tiers, monitor, test console, settings.
   - Ensure CRUD actions, filters, and loading/error states.
5. Story-agent additions:
   - Add `/v1/admin/dry-run`.
   - Load effective policy/templates/tiers from Firestore.
   - Enforce blocking on generation endpoints.
   - Log user generation to `generation_logs_v1` and admin dry-runs to `test_runs_v1`.
6. Firestore rules draft:
   - Lock admin collections to `admin=true`.
   - Keep user-scoped data constrained to owner/admin access.
7. Validation:
   - `flutter analyze`, `flutter test`, `flutter build web` for admin app.
   - `npm test`, `npm run build` for story-agent.
