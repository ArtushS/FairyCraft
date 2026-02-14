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

## 5) CI

- GitHub Actions workflow: `.github/workflows/server-ci.yml`
- Runs on changes in `server/story-agent/**`: `npm ci` + `npm test`

## 6) Security notes

- No real secrets are committed.
- `.env*`, keystores, and Firebase config files are gitignored.
- Android release signing for the client is guarded in `apps/fairycraft_app/android/app/build.gradle.kts`.
