import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { verifyTransaction } from "./appStoreClient";

interface VerifyPurchaseRequest {
  transactionId: string;
}

export const verifyPurchase = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const { transactionId } = request.data as Partial<VerifyPurchaseRequest>;
  if (!transactionId) {
    throw new HttpsError("invalid-argument", "Missing transactionId.");
  }

  const result = await verifyTransaction(transactionId);
  if (!result.isValid) {
    throw new HttpsError("permission-denied", "Transaction could not be verified.");
  }

  const userRef = getFirestore().collection("users").doc(request.auth.uid);
  await userRef.set({ entitlement: { hasGearPack: true } }, { merge: true });

  const snapshot = await userRef.get();
  return { entitlement: snapshot.data()?.entitlement ?? { hasGearPack: true } };
});
