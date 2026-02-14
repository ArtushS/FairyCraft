# Secrets and Keys

No real secrets are stored in this repository.

## Must stay local / secret storage only

- `server/story-agent/.env`
- `apps/fairycraft_app/android/keystore.properties`
- Android keystore file (`.jks` / `.keystore`)
- `apps/fairycraft_app/android/app/google-services.json`
- `apps/fairycraft_app/ios/Runner/GoogleService-Info.plist`
- `apps/fairycraft_admin/android/app/google-services.json`
- `apps/fairycraft_admin/ios/Runner/GoogleService-Info.plist`

## Firebase setup

1. Run `flutterfire configure` in `apps/fairycraft_app`.
2. Run `flutterfire configure` in `apps/fairycraft_admin`.
3. Replace placeholder `firebase_options.dart` files with generated output.
4. Configure App Check debug token for development devices.

## Cloud Run / server env vars (names only)

- `GOOGLE_CLOUD_PROJECT`
- `STORAGE_BUCKET`
- `VERTEX_LOCATION`
- `GEMINI_MODEL`
- `VERTEX_IMAGE_MODEL`
- `AUTH_REQUIRED`
- `APPCHECK_REQUIRED`
- `MOCK_ENGINE`
- `STORE_DISABLED`
- `POLICY_MODE` (optional deployment variable)

## Android release signing

- Copy `apps/fairycraft_app/android/keystore.properties.example` to `apps/fairycraft_app/android/keystore.properties`.
- Fill:
  - `storeFile`
  - `storePassword`
  - `keyAlias`
  - `keyPassword`

Release build is configured to fail if signing config is missing.

## Optional Meta/Facebook token

If `flutter_facebook_auth` is used in production, keep token only in secure secret storage (not git).

## Recommended secret locations

- Local dev: local files only (`.env`, keystore, Firebase native config files)
- CI: secret variables in CI provider
- Cloud: Secret Manager / runtime secret store
