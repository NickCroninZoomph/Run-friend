import { initializeApp } from "firebase-admin/app";

initializeApp();

export { stravaOAuthCallback } from "./strava/stravaOAuthCallback";
export { stravaGetActivities } from "./strava/stravaGetActivities";
export { generateAvatar } from "./generation/generateAvatar";
export { verifyPurchase } from "./purchases/verifyPurchase";
