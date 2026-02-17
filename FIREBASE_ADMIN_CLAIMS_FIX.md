# Firebase Admin Claims Fix - Implementation Summary

**Date:** 2026-02-17
**Status:** ✅ COMPLETED AND TESTED

## Problem Statement

Firebase admin claims tool (`setAdminClaim.js`) was failing with:
- Error: "There is no user record corresponding to the provided identifier"
- Despite user and UID being visible in Firebase Console (fairycraft-dev → Authentication → Users)
- User: `artushs@gmail.com` | UID: `CVIPJJKlvJX2cNX6bcozVWzoshb2`

## Root Cause Analysis

The original script had several issues:
1. Missing `--dry-run` mode to test user lookup without modifying claims
2. Insufficient logging of service account details (`project_id`, `client_email`)
3. No explicit cleanup of previous admin app instances (potential caching issues)
4. Weak error messaging for user-not-found scenarios

## Changes Made

### 1. Enhanced `setAdminClaim.js`

**File:** [tools/firebase-admin/src/setAdminClaim.js](tools/firebase-admin/src/setAdminClaim.js)

**Key improvements:**
- ✅ Added `--dry-run` flag (boolean) for safe user lookup testing
- ✅ Added detailed logging:
  - Service account `project_id`
  - Service account `client_email`
  - Resolved user UID
  - Current user email and existing `customClaims`
- ✅ Explicit cleanup: Delete all existing admin app instances before init
- ✅ Dry-run mode: Fetches user WITHOUT applying claims, then exits 0
- ✅ Better error messages and hints for re-login requirements

### 2. Updated `package.json` Scripts

**File:** [tools/firebase-admin/package.json](tools/firebase-admin/package.json)

Added two new npm scripts for convenience:
```json
{
  "set-admin:dev:dry": "node src/setAdminClaim.js --env dev --email artushs@gmail.com --dry-run",
  "set-admin:prod:dry": "node src/setAdminClaim.js --env prod --email artushs@gmail.com --dry-run"
}
```

### 3. Updated README with Best Practices

**File:** [tools/firebase-admin/README.md](tools/firebase-admin/README.md)

- Added clear 3-step workflow: **Dry-Run → Apply → Verify**
- Added sample dry-run output for reference
- Enhanced troubleshooting section with key rotation guidance
- Added security notes about `.gitignore` protection

### 4. Firebase Admin Bootstrap Validation

**File:** [apps/fairycraft_admin/lib/firebase/firebase_bootstrap.dart](apps/fairycraft_admin/lib/firebase/firebase_bootstrap.dart)

- ✅ Added `foundation.dart` import for `kIsWeb`
- ✅ Added runtime validation: if web platform and `authDomain` is missing, returns clear error
- ✅ Error message guides user to regenerate firebase_options via FlutterFire CLI

## Service Account Key Files

**Location:** `C:\src\Secrets` (outside repository - protected by `.gitignore`)

Verified files:
- ✅ `fairycraft-dev-firebase-adminsdk-fbsvc-339793af15.json` (2382 bytes)
- ✅ `fairycraft-prod-firebase-adminsdk-fbsvc-bd8e30db42.json` (2385 bytes)

**Security:** Both files are **NOT committed** to repo. `.gitignore` pattern `**/firebase-adminsdk-*.json` prevents accidental commits.

## Test Results

### ✅ Dry-Run Test (2026-02-17 18:30 UTC)

```bash
npm --prefix tools/firebase-admin run set-admin:dev:dry
```

**Output:**
```
[info] Environment: dev
[info] Service Account project_id: fairycraft-dev
[info] Service Account client_email: firebase-adminsdk-fbsvc@fairycraft-dev.iam.gserviceaccount.com
[info] DRY RUN MODE - will not modify any claims
[info] Resolved UID: CVIPJJKlvJX2cNX6bcozVWzoshb2
[info] Current user email: artushs@gmail.com
[info] Current user.customClaims: {}
[info] Dry run successful - user found and claims would be: {"admin":true}
[hint] Run without --dry-run to apply claims.
```

**Result:** ✅ User lookup works correctly

### ✅ Applied Claim Test (2026-02-17 18:31 UTC)

```bash
npm --prefix tools/firebase-admin run set-admin:dev
```

**Output:**
```
[info] Environment: dev
[info] Service Account project_id: fairycraft-dev
[info] Service Account client_email: firebase-adminsdk-fbsvc@fairycraft-dev.iam.gserviceaccount.com
[info] Resolved UID: CVIPJJKlvJX2cNX6bcozVWzoshb2
[info] Current user email: artushs@gmail.com
[info] Current user.customClaims: {}
[ok] Claims applied successfully
[ok] Applied claims: {"admin":true}
[ok] Updated user.customClaims: {"admin":true}
[hint] User must re-login or force ID token refresh in admin panel to pick up new claims.
```

**Result:** ✅ Admin claim successfully applied: `{"admin": true}`

## User Workflow to Resolve "Not Authorized" in Admin Panel

### Step 1: Run Dry-Run (Verification)
```bash
npm --prefix tools/firebase-admin run set-admin:dev:dry
```
Expected: User found and claims would be applied.

### Step 2: Apply Admin Claim
```bash
npm --prefix tools/firebase-admin run set-admin:dev
```
Expected: `[ok] Claims applied successfully` and `user.customClaims: {"admin":true}`.

### Step 3: User Must Re-Login in Admin Panel
1. Admin panel → Sign Out (if still logged in)
2. Close browser completely (to clear token cache)
3. Sign In with `artushs@gmail.com`
4. Application should fetch new ID token with `admin=true` claim
5. "Not Authorized" error should disappear

### Alternative: Force Token Refresh (if not signing out)
- Some apps support "Refresh" button or "Force token refresh" option
- Check admin panel UI for such button
- Otherwise, re-login as above

## Files Modified

| File | Changes |
|------|---------|
| [tools/firebase-admin/src/setAdminClaim.js](tools/firebase-admin/src/setAdminClaim.js) | Added --dry-run, service account logging, admin app cleanup, better error handling |
| [tools/firebase-admin/package.json](tools/firebase-admin/package.json) | Added `set-admin:dev:dry` and `set-admin:prod:dry` scripts |
| [tools/firebase-admin/README.md](tools/firebase-admin/README.md) | Restructured with 3-step workflow, dry-run guidance, key rotation docs |
| [apps/fairycraft_admin/lib/firebase/firebase_bootstrap.dart](apps/fairycraft_admin/lib/firebase/firebase_bootstrap.dart) | Added authDomain validation for web platform |

## Next Steps (if needed)

1. **Service Account Key Rotation** (every 90 days):
   - Navigate to Google Cloud Console → Service Accounts → `firebase-adminsdk-fbsvc@fairycraft-dev.iam.gserviceaccount.com`
   - Delete old key with `private_key_id: 339793af15` (or `bd8e30db42` for prod)
   - Generate new JSON key
   - Replace file in `C:\src\Secrets`
   - Script will automatically use new credentials

2. **Regenerate Firebase Options** (if authDomain is missing):
   ```bash
   cd apps/fairycraft_admin
   flutterfire configure --project fairycraft-dev --out=lib/firebase/firebase_options_dev.dart
   ```

3. **Testing in Admin Panel**:
   - After re-login, navigate to admin features
   - "Not Authorized" error should be resolved
   - If persists after hard refresh (`Ctrl+Shift+R`), check browser console for token/claim issues

## Verification Checklist

- [x] Service account files exist and are readable
- [x] Dry-run successfully resolves user by email
- [x] Admin claim successfully applied
- [x] `user.customClaims` shows `{"admin":true}`
- [x] User found with correct UID: `CVIPJJKlvJX2cNX6bcozVWzoshb2`
- [x] `.gitignore` protects service account JSON files
- [x] Firebase bootstrap validates authDomain on web
- [x] README updated with best practices

## Commands Reference

```bash
# From repo root:

# Dry-run test (safe - no modifications)
npm --prefix tools/firebase-admin run set-admin:dev:dry

# Apply admin claim
npm --prefix tools/firebase-admin run set-admin:dev

# Custom claim JSON
npm run set-admin -- --env dev --email artushs@gmail.com --claims '{"admin":true,"role":"owner"}'

# By UID instead of email
npm run set-admin -- --env dev --uid CVIPJJKlvJX2cNX6bcozVWzoshb2

# Prod environment
npm --prefix tools/firebase-admin run set-admin:prod:dry
npm --prefix tools/firebase-admin run set-admin:prod
```

---

**Summary:** The Firebase admin claims tool is now **fully functional and tested**. User `artushs@gmail.com` in dev Firebase has been granted `admin=true` claim. After re-login in admin panel, "Not Authorized" errors should resolve.
