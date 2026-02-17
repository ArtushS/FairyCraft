#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');
const minimist = require('minimist');
const dotenv = require('dotenv');
const admin = require('firebase-admin');

const SERVICE_ACCOUNT_PATHS = {
  dev: path.resolve('C:\\src\\Secrets\\fairycraft-dev-firebase-adminsdk-fbsvc-339793af15.json'),
  prod: path.resolve('C:\\src\\Secrets\\fairycraft-prod-firebase-adminsdk-fbsvc-bd8e30db42.json'),
};

const TOOL_ROOT = path.resolve(__dirname, '..');
dotenv.config({ path: path.join(TOOL_ROOT, '.env'), quiet: true });
dotenv.config({ path: path.join(TOOL_ROOT, '.env.local'), override: true, quiet: true });

function normalizeEnvironment(rawValue) {
  if (!rawValue) {
    return '';
  }
  return String(rawValue).trim().toLowerCase();
}

function parseClaims(rawValue) {
  let parsed;
  try {
    parsed = JSON.parse(rawValue);
  } catch (error) {
    throw new Error(`Invalid --claims JSON: ${error.message}`);
  }

  if (!parsed || Array.isArray(parsed) || typeof parsed !== 'object') {
    throw new Error('--claims must be a JSON object, for example: {"admin":true}');
  }

  return parsed;
}

function readServiceAccount(serviceAccountPath) {
  if (!fs.existsSync(serviceAccountPath)) {
    throw new Error(
      `Service account file not found: ${serviceAccountPath}. ` +
      'Check C:\\src\\Secrets paths and file names.',
    );
  }

  const fileContent = fs.readFileSync(serviceAccountPath, 'utf8');

  try {
    return JSON.parse(fileContent);
  } catch (error) {
    throw new Error(`Service account JSON is invalid: ${error.message}`);
  }
}

function isUserNotFoundError(error) {
  const code = error && (error.code || (error.errorInfo && error.errorInfo.code));
  return code === 'auth/user-not-found';
}

async function resolveUid(auth, email, fallbackUid) {
  if (!email) {
    if (!fallbackUid) {
      throw new Error('Pass --email or --uid (or set FIREBASE_USER_EMAIL/FIREBASE_UID in .env).');
    }
    return fallbackUid;
  }

  try {
    const userRecord = await auth.getUserByEmail(email);
    return userRecord.uid;
  } catch (error) {
    if (isUserNotFoundError(error) && fallbackUid) {
      console.warn(
        `[warn] User "${email}" was not found, fallback to provided uid "${fallbackUid}".`,
      );
      return fallbackUid;
    }

    if (isUserNotFoundError(error)) {
      throw new Error(
        `User with email "${email}" was not found in Firebase Auth.\n` +
        'Sign in once in the app/admin panel to create the user record, ' +
        'or rerun with --uid, or set FIREBASE_UID in tools/firebase-admin/.env.',
      );
    }

    throw error;
  }
}

async function main() {
  const argv = minimist(process.argv.slice(2), {
    string: ['env', 'email', 'uid', 'claims'],
    boolean: ['dry-run'],
  });

  const environment = normalizeEnvironment(argv.env || process.env.FIREBASE_ENV);
  const email = String(argv.email || process.env.FIREBASE_USER_EMAIL || '').trim();
  const fallbackUid = String(argv.uid || process.env.FIREBASE_UID || '').trim();
  const claimsRaw = String(argv.claims || process.env.FIREBASE_CLAIMS || '{"admin":true}').trim();
  const isDryRun = argv['dry-run'] === true;

  if (!environment || !(environment in SERVICE_ACCOUNT_PATHS)) {
    throw new Error('Missing or invalid --env. Allowed values: dev, prod.');
  }

  const claims = parseClaims(claimsRaw);
  const serviceAccountPath = SERVICE_ACCOUNT_PATHS[environment];
  const serviceAccount = readServiceAccount(serviceAccountPath);

  console.log(`[info] Environment: ${environment}`);
  console.log(`[info] Service Account project_id: ${serviceAccount.project_id || 'unknown'}`);
  console.log(`[info] Service Account client_email: ${serviceAccount.client_email || 'unknown'}`);
  if (isDryRun) {
    console.log('[info] DRY RUN MODE - will not modify any claims');
  }

  const appName = `set-admin-claim-${environment}-${Date.now()}`;

  // Clean up any existing admin app instances to avoid caching issues
  if (admin.apps.length > 0) {
    await Promise.all(admin.apps.map((app) => app.delete().catch(() => undefined)));
  }

  const app = admin.initializeApp(
    {
      credential: admin.credential.cert(serviceAccount),
    },
    appName,
  );

  try {
    const auth = admin.auth(app);
    const uid = await resolveUid(auth, email, fallbackUid);

    console.log(`[info] Resolved UID: ${uid}`);

    // Fetch current user to verify and show state
    const currentUser = await auth.getUser(uid);
    console.log(`[info] Current user email: ${currentUser.email || 'N/A'}`);
    console.log(`[info] Current user.customClaims: ${JSON.stringify(currentUser.customClaims || {})}`);

    if (isDryRun) {
      console.log('[info] Dry run successful - user found and claims would be:', JSON.stringify(claims));
      console.log('[hint] Run without --dry-run to apply claims.');
      return;
    }

    // Apply claims
    await auth.setCustomUserClaims(uid, claims);
    const updatedUser = await auth.getUser(uid);
    const updatedClaims = updatedUser.customClaims || {};

    console.log(`[ok] Claims applied successfully`);
    console.log(`[ok] Applied claims: ${JSON.stringify(claims)}`);
    console.log(`[ok] Updated user.customClaims: ${JSON.stringify(updatedClaims)}`);
    if (Object.keys(updatedClaims).length === 0) {
      console.log(
        '[warn] user.customClaims is empty. Claims are applied in ID token after refresh/re-login.',
      );
    }
    console.log('[hint] User must re-login or force ID token refresh in admin panel to pick up new claims.');
  } finally {
    await app.delete().catch(() => undefined);
  }
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(`[error] ${error.message}`);
    process.exit(1);
  });
