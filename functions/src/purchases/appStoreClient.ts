import { isAppStoreConfigured } from "../config";

export interface PurchaseVerificationResult {
  isValid: boolean;
  productId?: string;
}

/**
 * Verifies a StoreKit 2 transaction with the App Store Server API. Falls
 * back to trusting the client-supplied transactionId in mock mode until App
 * Store Connect credentials are configured — never do this in production.
 *
 * TODO: real implementation needs a signed JWT (ES256, using
 * config.appStore.keyId/issuerId/privateKey) sent as a Bearer token to
 * https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transactionId}
 * See https://developer.apple.com/documentation/appstoreserverapi
 */
export async function verifyTransaction(transactionId: string): Promise<PurchaseVerificationResult> {
  if (!isAppStoreConfigured()) {
    return { isValid: true, productId: "com.runfriend.gearpack" };
  }

  throw new Error(`App Store Server API verification not yet implemented (transaction ${transactionId})`);
}
