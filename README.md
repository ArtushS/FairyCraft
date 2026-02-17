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

### Admin dry-run quick test

1. Open Admin -> `Test Console`.
2. Fill required scenario inputs.
3. Optionally fill family names and siblings lists.
4. Click `Run dry-run through gateway`.
5. Verify:
   - `decision.status`
   - `effectivePolicyId`
   - `composedPayload.prompt.userSummary` includes family context.

## 6) CI

- GitHub Actions workflow: `.github/workflows/server-ci.yml`
- Runs on changes in `server/story-agent/**`: `npm ci` + `npm test`

## 7) Localization (app)

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

## 8) Policy Migration (`allowPersonalNames`)

- Server default remains safe for legacy docs: if `contentRules.allowPersonalNames` is missing, it is treated as `true`.
- Admin includes a dev-only maintenance action in Policies:
  - `Backfill allowPersonalNames`
  - Scans `policies_v1`, updates only documents missing `contentRules.allowPersonalNames`, and reports scanned/updated/skipped.
- Recommended rollout:
  1. Open Admin (dev), run backfill, verify summary.
  2. Open Admin (prod), run backfill, verify summary.

## 9) Admin Web Deploy (dev/prod)

- Hosting is configured from repo root and must point to Flutter admin build output:
  - `firebase.json` -> `hosting.public = "apps/fairycraft_admin/build/web"`

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

## 10) Security notes

- No real secrets are committed.
- `.env*`, keystores, and Firebase config files are gitignored.
- Android release signing for the client is guarded in `apps/fairycraft_app/android/app/build.gradle.kts`.
