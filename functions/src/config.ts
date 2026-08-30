/**
 * Central place to read secrets/config, all via environment variables so
 * they can be set with `firebase functions:secrets:set` (or a local `.env`
 * for the emulator) rather than committed anywhere. Any integration whose
 * secret is missing runs in mock mode until the real account/key exists.
 */
export const config = {
  strava: {
    clientId: process.env.STRAVA_CLIENT_ID ?? "",
    clientSecret: process.env.STRAVA_CLIENT_SECRET ?? "",
    redirectUri: process.env.STRAVA_REDIRECT_URI ?? "",
  },
  gemini: {
    apiKey: process.env.GEMINI_API_KEY ?? "",
  },
  appStore: {
    issuerId: process.env.APP_STORE_ISSUER_ID ?? "",
    keyId: process.env.APP_STORE_KEY_ID ?? "",
    privateKey: process.env.APP_STORE_PRIVATE_KEY ?? "",
    bundleId: process.env.APP_STORE_BUNDLE_ID ?? "com.runfriend.app",
  },
} as const;

export const isStravaConfigured = (): boolean =>
  Boolean(config.strava.clientId && config.strava.clientSecret);

export const isGeminiConfigured = (): boolean => Boolean(config.gemini.apiKey);

export const isAppStoreConfigured = (): boolean =>
  Boolean(config.appStore.issuerId && config.appStore.keyId && config.appStore.privateKey);
