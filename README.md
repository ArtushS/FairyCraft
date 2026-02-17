# FairyCraft Monorepo

FairyCraft is a clean monorepo with three independent apps:

- `apps/fairycraft_app` - main Flutter client.
- `apps/fairycraft_admin` - separate Flutter admin panel.
- `server/story-agent` - Node.js/TypeScript Cloud Run Story Agent.

## 1) Run locally (no external services)

### Server (`server/story-agent`)

```powershell
cd server/story-agent
Copy-Item .env.example .env
# in .env keep MOCK_ENGINE=true and STORE_DISABLED=true
npm ci
npm test
npm run build
npm start
```

### Main app (`apps/fairycraft_app`)

```powershell
cd apps/fairycraft_app
flutter pub get
flutter run -d chrome --dart-define=USE_MOCK_STORIES=true --dart-define=STORY_AGENT_URL=http://localhost:8080/
```

### Admin app (`apps/fairycraft_admin`)

```powershell
cd apps/fairycraft_admin
flutter pub get
flutter run -d chrome --dart-define=USE_MOCK_ADMIN=true
```

## 2) Connect Firebase

1. Install FlutterFire CLI and run `flutterfire configure` for each Flutter app.
2. Replace placeholder `firebase_options.dart` with generated files.
3. Keep Firebase platform files local (do not commit):
   - `google-services.json`
   - `GoogleService-Info.plist`
4. Configure App Check debug token for local development.

## 3) Deploy `server/story-agent` to Cloud Run

1. Build image from `server/story-agent/Dockerfile`.
2. Deploy with runtime env vars (see `server/story-agent/.env.example`).
3. For production set at least:
   - `AUTH_REQUIRED=true`
   - `APPCHECK_REQUIRED=true`
   - `MOCK_ENGINE=false`
   - `STORE_DISABLED=false`
   - `GOOGLE_CLOUD_PROJECT`
   - `VERTEX_LOCATION`
   - `GEMINI_MODEL`
   - `VERTEX_IMAGE_MODEL`
   - `STORAGE_BUCKET`

## 4) Firebase Rules

- Firestore rules: `firebase/firestore.rules`
- Storage rules: `firebase/storage.rules`
- Firebase Tools config: `firebase/firebase.json`
- All default reads/writes are restricted to authenticated, AppCheck-verified clients.
- Admin panel access is controlled via custom claims (see `ADMIN_CLAIM_QUICK_REF.md`).

## 5) Story Request v0.0.1 Fields

Client generate payload now includes:

- `age` and `ageGroup`
- `storyLength`
- `complexity` (`simple|normal`)
- `creativity` (`low|normal|high`)
- `illustrationsEnabled` and `image.enabled`
- `parentalControls`:
  - `safeMode`
  - `disableScaryContent`
  - `requireParentConfirmationForOlder`
- Family context:
  - `familyMembers` counts
  - optional `familyNames` for `mom|dad|grandma|grandpa`
  - optional `brothers[]` and `sisters[]`

Server validates these fields in `server/story-agent/src/schemas.ts` and maps them into policy `dry-run`/composition flow.

**Privacy note:** Personal names included in requests are logged (server-side) only for audit purposes and are never exposed in UI or returned to client. Admin test runs redact these names in on-screen displays (see section 8).

### Admin dry-run quick test

1. Open Admin → **Test Console**.
2. Fill required scenario inputs (age, tier, language, hero type, story idea, etc.).
3. Optionally fill family names and siblings lists to test family context.
4. Click **Run dry-run through gateway**.
5. Verify on-screen:
   - `Effective Policy` header and matched templates count
   - `Composed Payload` (redacted for display; see section 8)
   - `Gateway Response` with decision status
6. Behind the scenes, raw payloads are stored in `test_runs_v1` for audit/debugging.

## 6) CI

- GitHub Actions workflow: `.github/workflows/server-ci.yml`
- Runs on changes in `server/story-agent/**`: `npm ci` + `npm test`

## 7) Localization

### App localization

- Flutter app localization files:
  - `apps/fairycraft_app/lib/l10n/app_en.arb`
  - `apps/fairycraft_app/lib/l10n/app_ru.arb`
  - `apps/fairycraft_app/lib/l10n/app_hy.arb`
- New UI text must be added to ARB keys and used from `context.l10n` (no hardcoded user-facing strings in app screens).
- Regenerate localization classes after ARB updates:

```powershell
cd apps/fairycraft_app
flutter gen-l10n
```

### Admin localization

- Admin app supports English, Russian, and Armenian localization:
  - `apps/fairycraft_admin/lib/l10n/app_en.arb`
  - `apps/fairycraft_admin/lib/l10n/app_ru.arb`
  - `apps/fairycraft_admin/lib/l10n/app_hy.arb`
- Localized pages: Policies, Templates, Test Console
- All user-facing labels use generated `AppLocalizations` from l10n files.
- To add new admin UI strings:
  1. Add keys to all three ARB files with translations.
  2. Regenerate localization:

```powershell
cd apps/fairycraft_admin
flutter gen-l10n
```

## 8) Admin Console Security & PII Redaction

### Test Console

- **Do not display raw personal names on-screen.** The admin test console sanitizes JSON output to redact:
  - `familyNames` (all role names)
  - `brothers[]` and `sisters[]` (replaced with 'REDACTED' in UI display)
  - Nested maps/lists containing these fields are recursively sanitized.
- Raw payloads are still stored in `test_runs_v1` Firestore for audit/debugging.
- The sanitizer is implemented in `_sanitizeForDisplay()` in `test_console_page.dart` and applied to all JSON card displays.

## 9) Policy Migration & Backfill (`allowPersonalNames`)

### Migration strategy

- **Server default:** If `contentRules.allowPersonalNames` is missing from a policy doc, it is treated as `true` (safe for legacy documents).
- **Admin backfill tool:** Quickly normalize all policies across environments.

### Using the backfill tool

1. Navigate to Admin → Policies.
2. Click **Backfill allowPersonalNames** button.
3. Tool scans all `policies_v1` docs and:
   - Updates documents missing `contentRules.allowPersonalNames: true`
   - Skips documents that already have the field set
   - Reports: scanned count, updated count, skipped count
4. Repeat for each environment (dev → prod).

**Note:** The raw payloads and admin test runs are sanitized for display but stored in full for audit purposes. Always run backfill in dev first to verify behavior before prod.

## 10) Admin Web Deploy (dev/prod)

- Hosting is configured from repo root and must point to Flutter admin build output:
  - `firebase.json` -> `hosting.public = "apps/fairycraft_admin/build/web"`
- Admin is fully localized and supports EN/RU/HY via browser locale.

### Deploy dev

```powershell
cd apps/fairycraft_admin
flutter build web --dart-define=FLAVOR=dev --dart-define=USE_MOCK_ADMIN=false
cd ../..
firebase use fairycraft-dev
firebase deploy --only hosting
```

### Deploy prod

```powershell
cd apps/fairycraft_admin
flutter build web --dart-define=FLAVOR=prod --dart-define=USE_MOCK_ADMIN=false
cd ../..
firebase use fairycraft-prod
firebase deploy --only hosting
```

## 11) Security notes

- No real secrets are committed.
- `.env*`, keystores, and Firebase config files are gitignored.
- Android release signing for the client is guarded in `apps/fairycraft_app/android/app/build.gradle.kts`.
- Admin console test runs and gateway responses are redacted on-screen to prevent accidental PII leaks (see section 8).
- All policy backfill operations are logged and auditable via Firestore.
