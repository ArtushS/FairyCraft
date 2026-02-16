import type { RequestHandler } from 'express';

import type { AppConfig } from '../config';
import { getAppCheckVerifier, getAuthVerifier } from '../services/firebaseAdmin';

const parseBearerToken = (headerValue: string | undefined): string | undefined => {
  if (!headerValue) {
    return undefined;
  }
  const [scheme, token] = headerValue.split(' ');
  if (scheme?.toLowerCase() !== 'bearer' || !token) {
    return undefined;
  }
  return token;
};

export const createAuthMiddleware = (config: AppConfig): RequestHandler => {
  return async (req, res, next) => {
    let uid = 'anonymous';
    let appCheckVerified = false;
    let isAdmin = false;

    const bearer = parseBearerToken(req.header('authorization'));
    if (config.authRequired && !bearer) {
      res.status(401).json({ ok: false, error: 'auth_required', safeMessage: 'Authentication is required.' });
      return;
    }

    if (bearer) {
      try {
        const decoded = await getAuthVerifier().verifyIdToken(bearer);
        uid = decoded.uid;
        isAdmin = decoded.admin === true;
      } catch (error) {
        if (config.authRequired) {
          res.status(401).json({ ok: false, error: 'invalid_auth_token', safeMessage: 'Authentication token is invalid.' });
          return;
        }
      }
    }

    const appCheckToken = req.header('x-firebase-appcheck');
    if (config.appCheckRequired && !appCheckToken) {
      res.status(401).json({ ok: false, error: 'appcheck_required', safeMessage: 'App Check token is required.' });
      return;
    }

    if (appCheckToken) {
      try {
        await getAppCheckVerifier().verifyToken(appCheckToken);
        appCheckVerified = true;
      } catch (error) {
        if (config.appCheckRequired) {
          res.status(401).json({ ok: false, error: 'invalid_appcheck_token', safeMessage: 'App Check token is invalid.' });
          return;
        }
      }
    }

    req.fairycraftAuth = { uid, appCheckVerified, isAdmin };
    next();
  };
};
