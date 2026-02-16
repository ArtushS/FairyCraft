export {};

declare global {
  namespace Express {
    interface Request {
      fairycraftAuth?: {
        uid: string;
        appCheckVerified: boolean;
        isAdmin: boolean;
      };
    }
  }
}
