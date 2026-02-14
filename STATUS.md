# FairyCraft Status

## Milestones

- `M1 Scaffold`: completed
- `M2 Server`: completed
- `M3 Flutter App`: completed
- `M4 Admin App + Docs`: completed

## Commands executed

### M1

- `git init`
- `git status --short`
- `flutter pub get` (`apps/fairycraft_app`)
- `flutter pub get` (`apps/fairycraft_admin`)
- `npm test` (`server/story-agent`)

### M2

- `npm test` (`server/story-agent`)
- `npm run build` (`server/story-agent`)
- `node dist/index.js` smoke + `GET /healthz` check

### M3

- `flutter pub get` (`apps/fairycraft_app`)
- `flutter analyze` (`apps/fairycraft_app`)
- `flutter test` (`apps/fairycraft_app`)
- `flutter run -d windows --no-resident --dart-define=USE_MOCK_STORIES=true` (failed in this environment: missing `nuget.exe` for `flutter_tts` Windows build)
- `flutter run -d chrome --no-resident --dart-define=USE_MOCK_STORIES=true --dart-define=STORY_AGENT_URL=http://localhost:8080/` (success)

### M4

- `flutter pub get` (`apps/fairycraft_admin`)
- `flutter analyze` (`apps/fairycraft_admin`)
- `flutter run -d chrome --no-resident --dart-define=USE_MOCK_ADMIN=true` (success)
- `npm test` (`server/story-agent`)
- `rg forbidden-pattern-scan` (no matches after verification)

## Manual fill required (names only)

- `server/story-agent/.env`:
  - `GOOGLE_CLOUD_PROJECT`
  - `VERTEX_LOCATION`
  - `GEMINI_MODEL`
  - `VERTEX_IMAGE_MODEL`
  - `STORAGE_BUCKET`
  - `AUTH_REQUIRED`
  - `APPCHECK_REQUIRED`
  - `MOCK_ENGINE`
  - `STORE_DISABLED`
- `apps/fairycraft_app/android/keystore.properties`:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`
- Firebase client config files (local only):
  - `apps/fairycraft_app/android/app/google-services.json`
  - `apps/fairycraft_app/ios/Runner/GoogleService-Info.plist`
  - `apps/fairycraft_admin/android/app/google-services.json`
  - `apps/fairycraft_admin/ios/Runner/GoogleService-Info.plist`
- Generated FlutterFire options:
  - `apps/fairycraft_app/lib/firebase/firebase_options.dart`
  - `apps/fairycraft_admin/lib/firebase_options.dart`

## Next step: connect Firebase / Cloud Run / Vertex

1. Run `flutterfire configure` in both Flutter apps and replace placeholder options.
2. Configure Firebase Auth + App Check and test real sign-in on client/admin.
3. Deploy `server/story-agent` to Cloud Run with `AUTH_REQUIRED=true`, `APPCHECK_REQUIRED=true`, `MOCK_ENGINE=false`, `STORE_DISABLED=false`.
4. Set Vertex and Storage env vars (`GOOGLE_CLOUD_PROJECT`, `VERTEX_*`, `STORAGE_BUCKET`) and validate text/image paths.
5. Publish Firestore/Storage rules from `firebase/` and verify admin-claim access boundaries.

