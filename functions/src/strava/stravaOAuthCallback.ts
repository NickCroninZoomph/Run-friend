import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { exchangeCodeForToken } from "./stravaClient";

/**
 * Strava redirects the browser here after the user approves the OAuth
 * consent screen. We exchange the code for tokens, store them, and hand
 * control back to the app via the `runfriend://` custom URL scheme.
 *
 * TODO(open question): `state` is currently trusted as-is as the Firebase
 * Auth uid. Before wiring this up to a real ASWebAuthenticationSession, it
 * needs to be a signed, short-lived token minted server-side (e.g. a custom
 * JWT) and verified here — otherwise anyone can bind an arbitrary uid's
 * Strava connection. See the README's open questions.
 *
 * TODO(open question): tokens are stored as plain fields below. Before
 * shipping, encrypt access_token/refresh_token at rest (e.g. Cloud KMS
 * envelope encryption) rather than relying on Firestore's disk-level
 * encryption alone.
 */
export const stravaOAuthCallback = onRequest(async (request, response) => {
  const { code, state, error } = request.query;

  if (error) {
    response.redirect(`runfriend://strava-callback?error=${encodeURIComponent(String(error))}`);
    return;
  }
  if (typeof code !== "string" || typeof state !== "string") {
    response.status(400).send("Missing code or state");
    return;
  }

  const uid = state;

  try {
    const token = await exchangeCodeForToken(code);
    await getFirestore()
      .collection("users")
      .doc(uid)
      .set(
        {
          strava: {
            athleteId: token.athlete?.id ?? null,
            accessToken: token.access_token,
            refreshToken: token.refresh_token,
            expiresAt: token.expires_at,
            connectedAt: Date.now(),
          },
        },
        { merge: true }
      );
    response.redirect("runfriend://strava-callback?success=true");
  } catch (err) {
    console.error("stravaOAuthCallback failed", err);
    response.redirect(`runfriend://strava-callback?error=${encodeURIComponent("token_exchange_failed")}`);
  }
});
