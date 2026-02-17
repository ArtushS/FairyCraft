# Firebase Admin Claims Tool

Utility script to set Firebase Custom Claims (default: `{"admin":true}`) for DEV/PROD.

## Prerequisites

- Node.js 18+
- Firebase service account keys already downloaded outside repo:
  - `C:\src\Secrets\fairycraft-dev-firebase-adminsdk-fbsvc-339793af15.json`
  - `C:\src\Secrets\fairycraft-prod-firebase-adminsdk-fbsvc-bd8e30db42.json`
- Permissions in Firebase project to manage Auth users/claims

## Quick Start (from repo root)

### Step 1: Dry-Run (Recommended)

Test user lookup **without** modifying claims:

```bash
npm --prefix tools/firebase-admin run set-admin:dev:dry
npm --prefix tools/firebase-admin run set-admin:prod:dry
```

### Step 2: Apply Claims

If dry-run shows user found, apply claims:

```bash
npm --prefix tools/firebase-admin run set-admin:dev
npm --prefix tools/firebase-admin run set-admin:prod
```

### Step 3: Verify in Admin Panel

After success, user must **re-login** to pick up new `admin` claim.

## Universal Commands

```bash
# Dry-run with email lookup
npm run set-admin -- --env dev --email artushs@gmail.com --dry-run

# Apply claims by email
npm run set-admin -- --env dev --email artushs@gmail.com

# Apply claims by UID (if email not found)
npm run set-admin -- --env dev --uid CVIPJJKlvJX2cNX6bcozVWzoshb2

# Custom claims JSON
npm run set-admin -- --env dev --email artushs@gmail.com --claims "{\"admin\":true,\"role\":\"owner\"}"
```

## Environment Variables (.env optional)

Create `tools/firebase-admin/.env` (local only) using `.env.example`:

```dotenv
FIREBASE_ENV=dev
FIREBASE_USER_EMAIL=artushs@gmail.com
FIREBASE_UID=
FIREBASE_CLAIMS={"admin":true}
```

Then run:

```bash
npm run set-admin
```

`FIREBASE_UID` is useful as fallback if email lookup returns `auth/user-not-found`.

## Verification & Troubleshooting

### Dry-Run Output

```
[info] Environment: dev
[info] Service Account project_id: fairycraft-dev
[info] Service Account client_email: firebase-adminsdk-fbsvc@fairycraft-dev.iam.gserviceaccount.com
[info] Resolved UID: CVIPJJKlvJX2cNX6bcozVWzoshb2
[info] Current user email: artushs@gmail.com
[info] Current user.customClaims: {}
[info] Dry run successful - user found and claims would be: {"admin":true}
```

### Common Issues

#### `auth/user-not-found`
- Sign in once in admin panel so Firebase Auth creates the user record
- Or provide UID: `--uid CVIPJJKlvJX2cNX6bcozVWzoshb2`
- Or set `FIREBASE_UID=...` in `.env`

#### Claims not visible in UI after script succeeds
- User must **re-login** (sign out → sign in)
- Hard refresh browser (`Ctrl+Shift+R` or clear site cache)

#### `Missing service account file`
- Confirm exact file path in `C:\src\Secrets`
- Verify file name matches pattern `fairycraft-{dev|prod}-firebase-adminsdk-*.json`

#### Service Account Key Rotation
- Rotate key in Google Cloud Console every 90 days
- Download new JSON key and replace file in `C:\src\Secrets`
- This script will automatically use the new credentials

## Security

- **Do not** copy service-account JSON files into this repository
- `.gitignore` protects `firebase-adminsdk-*.json` patterns
- Service account keys stored in `C:\src\Secrets` (outside repo)
