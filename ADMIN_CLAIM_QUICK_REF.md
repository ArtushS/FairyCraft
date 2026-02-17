# 🚀 Firebase Admin Claims - Quick Reference

## Problem Fixed ✅
- ~~"There is no user record corresponding to the provided identifier"~~
- ✅ User `artushs@gmail.com` (UID: `CVIPJJKlvJX2cNX6bcozVWzoshb2`) now has `admin=true` claim in dev

## Admin Panel Next Step

**User must re-login to pick up new admin claim:**

1. **Sign Out** from admin panel
2. **Close browser** completely (clear token cache)
3. **Sign In** with `artushs@gmail.com`
4. **"Not Authorized" error should disappear** ✅

---

## Verify Anytime

```bash
# From repo root - check if user has admin claim:
npm --prefix tools/firebase-admin run set-admin:dev:dry
```

**Expected output includes:**
```
[info] Resolved UID: CVIPJJKlvJX2cNX6bcozVWzoshb2
[info] Current user email: artushs@gmail.com
[info] Current user.customClaims: {"admin":true}  ← ✅ This confirms it worked
```

---

## For Other Users (Future)

```bash
# Add admin claim for another email
npm run set-admin -- --env dev --email another@example.com

# Or by UID if email lookup fails
npm run set-admin -- --env dev --uid <UID_FROM_FIREBASE_CONSOLE>

# Always dry-run first to test (safe):
npm run set-admin -- --env dev --email another@example.com --dry-run
```

---

## What Changed

| Item | Details |
|------|---------|
| **Script** | Enhanced with `--dry-run`, better logging, admin app cleanup |
| **Service Accounts** | Confirmed secure outside repo in `C:\src\Secrets` |
| **Firebase Setup** | Added web authDomain validation in admin bootstrap |
| **Docs** | Updated README with 3-step workflow and troubleshooting |

📄 **Full details:** [FIREBASE_ADMIN_CLAIMS_FIX.md](FIREBASE_ADMIN_CLAIMS_FIX.md)
