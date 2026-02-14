import admin from 'firebase-admin';

let initialized = false;
let initError: Error | null = null;

const ensureInitialized = (): void => {
  if (initialized || initError) {
    return;
  }
  try {
    admin.initializeApp();
    initialized = true;
  } catch (error) {
    const typed = error as Error;
    if (!/already exists/i.test(typed.message)) {
      initError = typed;
    } else {
      initialized = true;
    }
  }
};

export const getAuthVerifier = () => {
  ensureInitialized();
  if (initError) {
    throw initError;
  }
  return admin.auth();
};

export const getAppCheckVerifier = () => {
  ensureInitialized();
  if (initError) {
    throw initError;
  }
  return admin.appCheck();
};

export const getFirestore = () => {
  ensureInitialized();
  if (initError) {
    throw initError;
  }
  return admin.firestore();
};
