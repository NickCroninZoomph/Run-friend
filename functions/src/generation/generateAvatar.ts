import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { generateComposite } from "./geminiClient";

interface GenerateAvatarRequest {
  selfieBase64: string;
  statsCardBase64: string;
  styleId: string;
  styleTier: "flash" | "pro";
  styleReferenceBase64: string;
}

const FREE_GENERATION_LIMIT = 3;

export const generateAvatar = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const data = request.data as Partial<GenerateAvatarRequest>;
  if (!data.selfieBase64 || !data.statsCardBase64 || !data.styleReferenceBase64 || !data.styleTier) {
    throw new HttpsError("invalid-argument", "Missing selfie, stats card, style reference, or style tier.");
  }

  const userRef = getFirestore().collection("users").doc(request.auth.uid);

  // Entitlement check happens server-side against Firestore, never trusting
  // the client, since this gates real Gemini spend.
  //
  // TODO(open question): this is the lifetime-cap model from the spec. If
  // it flips to a monthly refresh (flagged in the README because
  // $0.05-0.15/image generation cost doesn't pencil out against a $1
  // lifetime unlock), also check/reset against a `periodResetsAt` field here.
  const canGenerate = await getFirestore().runTransaction(async (transaction) => {
    const snapshot = await transaction.get(userRef);
    const entitlement = snapshot.data()?.entitlement ?? { hasGearPack: false, generationsUsed: 0 };
    const allowed = entitlement.hasGearPack || entitlement.generationsUsed < FREE_GENERATION_LIMIT;
    if (!allowed) {
      return false;
    }
    transaction.set(
      userRef,
      { entitlement: { ...entitlement, generationsUsed: entitlement.generationsUsed + 1 } },
      { merge: true }
    );
    return true;
  });

  if (!canGenerate) {
    throw new HttpsError("resource-exhausted", "Free generation limit reached.");
  }

  const imageBase64 = await generateComposite({
    selfieBase64: data.selfieBase64,
    styleReferenceBase64: data.styleReferenceBase64,
    statsCardBase64: data.statsCardBase64,
    styleTier: data.styleTier,
  });

  return { imageBase64 };
});
