import { config, isStravaConfigured } from "../config";

export interface StravaTokenResponse {
  access_token: string;
  refresh_token: string;
  expires_at: number; // unix seconds
  athlete?: { id: number; firstname: string; lastname: string };
}

export interface StravaActivity {
  id: number;
  name: string;
  type: string;
  start_date: string;
  distance: number; // meters
  moving_time: number; // seconds
  total_elevation_gain: number; // meters
  average_heartrate?: number;
  calories?: number;
}

const MOCK_TOKEN: StravaTokenResponse = {
  access_token: "mock-access-token",
  refresh_token: "mock-refresh-token",
  expires_at: Math.floor(Date.now() / 1000) + 21_600,
  athlete: { id: 1, firstname: "Mock", lastname: "Runner" },
};

const MOCK_ACTIVITIES: StravaActivity[] = [
  {
    id: 1,
    name: "Morning Riverside Run",
    type: "Run",
    start_date: new Date(Date.now() - 86_400_000).toISOString(),
    distance: 8046.72,
    moving_time: 2460,
    total_elevation_gain: 45,
    average_heartrate: 152,
    calories: 512,
  },
  {
    id: 2,
    name: "Tempo Intervals",
    type: "Run",
    start_date: new Date(Date.now() - 3 * 86_400_000).toISOString(),
    distance: 6437.4,
    moving_time: 1740,
    total_elevation_gain: 22,
    average_heartrate: 168,
    calories: 430,
  },
];

/** Exchanges an OAuth `code` for tokens. Falls back to mock data until Strava creds are set. */
export async function exchangeCodeForToken(code: string): Promise<StravaTokenResponse> {
  if (!isStravaConfigured()) {
    return MOCK_TOKEN;
  }
  const response = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: config.strava.clientId,
      client_secret: config.strava.clientSecret,
      code,
      grant_type: "authorization_code",
    }),
  });
  if (!response.ok) {
    throw new Error(`Strava token exchange failed: ${response.status}`);
  }
  return (await response.json()) as StravaTokenResponse;
}

/** Refreshes an expired access token. Falls back to mock data until Strava creds are set. */
export async function refreshAccessToken(refreshToken: string): Promise<StravaTokenResponse> {
  if (!isStravaConfigured()) {
    return MOCK_TOKEN;
  }
  const response = await fetch("https://www.strava.com/oauth/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: config.strava.clientId,
      client_secret: config.strava.clientSecret,
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    }),
  });
  if (!response.ok) {
    throw new Error(`Strava token refresh failed: ${response.status}`);
  }
  return (await response.json()) as StravaTokenResponse;
}

/** Fetches the athlete's recent runs. Falls back to mock data until Strava creds are set. */
export async function fetchRecentActivities(accessToken: string, perPage = 10): Promise<StravaActivity[]> {
  if (!isStravaConfigured()) {
    return MOCK_ACTIVITIES;
  }
  const response = await fetch(`https://www.strava.com/api/v3/athlete/activities?per_page=${perPage}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!response.ok) {
    throw new Error(`Strava activities fetch failed: ${response.status}`);
  }
  const activities = (await response.json()) as StravaActivity[];
  return activities.filter((activity) => activity.type === "Run");
}
