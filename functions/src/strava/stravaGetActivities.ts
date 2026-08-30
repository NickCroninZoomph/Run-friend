import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { fetchRecentActivities, refreshAccessToken } from "./stravaClient";

interface StravaUserDoc {
  strava?: {
    accessToken: string;
    refreshToken: string;
    expiresAt: number;
  };
}

export const stravaGetActivities = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }

  const userRef = getFirestore().collection("users").doc(request.auth.uid);
  const snapshot = await userRef.get();
  const strava = (snapshot.data() as StravaUserDoc | undefined)?.strava;

  if (!strava) {
    throw new HttpsError("failed-precondition", "Strava is not connected.");
  }

  let accessToken = strava.accessToken;
  const isExpired = strava.expiresAt * 1000 < Date.now();
  if (isExpired) {
    const refreshed = await refreshAccessToken(strava.refreshToken);
    accessToken = refreshed.access_token;
    await userRef.set(
      {
        strava: {
          accessToken: refreshed.access_token,
          refreshToken: refreshed.refresh_token,
          expiresAt: refreshed.expires_at,
        },
      },
      { merge: true }
    );
  }

  const perPage = typeof request.data?.limit === "number" ? request.data.limit : 10;
  const activities = await fetchRecentActivities(accessToken, perPage);

  return {
    activities: activities.map((activity) => ({
      id: String(activity.id),
      name: activity.name,
      startDate: activity.start_date,
      distanceMeters: activity.distance,
      movingTimeSeconds: activity.moving_time,
      elevationGainMeters: activity.total_elevation_gain,
      averageHeartRate: activity.average_heartrate ?? null,
      calories: activity.calories ?? null,
      locationCity: activity.location_city ?? null,
      locationState: activity.location_state ?? null,
      // TODO(open question): still the raw encoded polyline — decode it
      // (Google's encoded polyline algorithm) and normalize to card-space
      // points, or render a real map snapshot, before this reaches
      // RunActivity.routePoints on the client. See README.
      mapSummaryPolyline: activity.map?.summary_polyline ?? null,
    })),
  };
});
