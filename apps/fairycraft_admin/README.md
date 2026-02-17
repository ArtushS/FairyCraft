# FairyCraft Admin (Web-first)

Flutter admin panel for policy/template/tier controls, request monitoring, and dry-run testing.

## Run locally (web)

```powershell
cd apps/fairycraft_admin
flutter pub get
flutter run -d chrome --dart-define=FLAVOR=dev
```

Optional local mock mode (no Firebase init):

```powershell
flutter run -d chrome --dart-define=FLAVOR=dev --dart-define=USE_MOCK_ADMIN=true
```

Optional local gateway URL override:

```powershell
flutter run -d chrome --dart-define=FLAVOR=dev --dart-define=ADMIN_GATEWAY_URL=http://localhost:8080
```

## Local debug admin UID bootstrap

For local development only, create an untracked file:

`apps/fairycraft_admin/web/local_admin_uids.json`

```json
{
  "uids": ["firebase-uid-1", "firebase-uid-2"]
}
```

This override is enabled only in `FLAVOR=dev` and is disabled in `FLAVOR=prod`.

## Routes

- `/login`
- `/`
- `/policies`
- `/templates`
- `/tiers`
- `/monitor`
- `/test-console`
- `/settings`

## Test Console (Dry-run)

`/test-console` now supports:

- Family counts via `familyMembers` map (`mom:1,dad:1,...`)
- Optional personal names:
  - mom, dad, grandma, grandpa
- Optional sibling name lists:
  - brothers
  - sisters

These fields are forwarded to `POST /v1/admin/dry-run` and reflected in composed payload output.

## Deploy later (placeholder)

1. Ensure `FLAVOR=prod` Firebase options are configured locally with `flutterfire configure`.
2. Build static web assets:

```powershell
flutter build web --release --dart-define=FLAVOR=prod
```

3. Deploy `build/web` to your hosting target (Firebase Hosting, Cloud Run static, or CDN).
