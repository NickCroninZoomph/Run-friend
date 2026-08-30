# Run Friend

Native iOS app: connect Strava, upload a selfie, pick a cartoon style, and
generate a stylized avatar holding your real run stats — exportable
straight to an Instagram Story.

## What's scaffolded here

```
RunFriend/                  # SwiftUI app (MVVM, iOS 17+, Swift Concurrency)
  project.yml                # XcodeGen project definition
  RunFriend/
    RunFriendApp.swift
    Core/
      Navigation/             AppRoute, AppCoordinator, RootView
      Models/                 RunActivity, RunStats, GenerationStyle, Entitlement, GeneratedAvatar
      Networking/              StravaAPI / GenerationAPI / PurchaseAPI protocols + Mock implementations
      StatsCard/               StatsCardView + StatsCardRenderer (ImageRenderer -> PNG)
      Branding/                RunFriendBrandMark + BrandMarkCompositor (composites the logo onto the result, deterministically, same reasoning as the stats card)
      Storage/                 EntitlementStore (local cache only; server is source of truth)
    Features/
      Onboarding, StravaConnect, ActivityPicker, PhotoUpload,
      StyleAndGenerate, Result, Paywall, Settings
      (each a View + ViewModel; the MVP flow is wired end-to-end with mock data)

functions/                  # Firebase Cloud Functions (Node 20, TypeScript)
  src/
    strava/     stravaOAuthCallback.ts, stravaGetActivities.ts, stravaClient.ts
    generation/ generateAvatar.ts, geminiClient.ts
    purchases/  verifyPurchase.ts, appStoreClient.ts
    config.ts   env-based secrets; anything unset falls back to mock data
firestore.rules, storage.rules, firebase.json
```

Every screen is wired with real navigation (`NavigationStack` + an
`AppCoordinator`) and talks to `Mock*API` implementations that return
canned data with a realistic delay (the `generateAvatar` mock sleeps ~3s to
stand in for the real 5–15s Gemini round trip). Nothing calls Strava or
Gemini for real yet — see "Before this can do anything real" below.

The four Cloud Functions build and type-check (`npm run build` in
`functions/`) and contain working request/response shapes, Firestore
reads/writes, and entitlement-gating logic. The actual Strava/Gemini/App
Store HTTP calls are implemented but gated behind `config.ts`: if a secret
is missing, each one **returns mock data instead of making the call**, so
you can deploy and exercise the whole flow before every account exists.

## Running it

**iOS app** — this container can't run Xcode, so the `.xcodeproj` isn't
generated/committed. On your Mac:
```
brew install xcodegen
cd RunFriend
xcodegen generate
open RunFriend.xcodeproj
```

**Functions**:
```
cd functions
npm install
cp .env.example .env   # fill in whatever secrets you already have; leave the rest blank
npm run build
firebase emulators:start --only functions,firestore
```

## Accounts still needed (from your spec)

- Apple Developer Program ($99/yr)
- App Store Connect IAP product ("Gear Pack")
- Strava API app + an active paid Strava subscription (~$11.99/mo, required to keep API access)
- Google Gemini API key
- Firebase project on the Blaze plan (required for Functions' outbound calls)

Until these exist, everything runs against mocks on both the client and
server — no code changes needed later, just fill in `.env`.

## Open questions — please weigh in before I build further

1. **Free-tier model: lifetime cap vs. monthly refresh.** You already flagged
   this — a true lifetime "3 free, then $1 unlimited forever" doesn't pencil
   out against $0.05–0.15/image. I've scaffolded the lifetime-cap version
   (`Entitlement.freeGenerationLimit` / `generatAvatar`'s Firestore
   transaction) since it's simpler, but left `periodResetsAt` on the model
   and TODOs in both `generateAvatar.ts` and `PaywallView` so a monthly
   refresh is a small, contained change. **My recommendation:** keep the
   Gear Pack as a one-time unlock of extra styles, but cap even paid users
   at something like 1–2 free generations/month refreshed automatically —
   avoids unbounded Gemini spend per user while still feeling generous
   after the $1 purchase.

2. **Reinstall / new-device recovery.** The spec uses Firebase anonymous
   auth specifically to avoid Sign-in-with-Apple friction — but an
   anonymous UID is device-local. If someone reinstalls the app or gets a
   new phone, they lose both their Strava connection *and* their Gear Pack
   entitlement, and Apple requires purchases to be restorable. Options:
   (a) link the anonymous Firebase user to Sign-in-with-Apple only when they
   buy the Gear Pack (invisible until money's involved), or (b) key
   entitlement off the Strava athlete ID instead of the Firebase UID once
   Strava's connected. Needs a decision before `verifyPurchase`/restore is
   built out for real.

3. **Units on the stats card.** Currently hardcoded to imperial (miles,
   feet) in `RunStats`. Should this follow device locale instead?

3b. **Route map rendering.** Per the reference designs you shared, the card
   now has a route thumbnail. `RunActivity.routePoints` is mock/placeholder
   data — real routes need Strava's encoded `map.summary_polyline` (now
   passed through by `stravaGetActivities.ts`, undecoded) turned into
   either normalized points for the current stylized-line thumbnail, or a
   real MapKit snapshot like the references show. MapKit gets you the
   actual map tiles but is more work (region fitting, snapshot rendering,
   attribution); the stylized line is what's implemented now. Which do you
   want for v1?

3c. **Achievement line data source.** The reference cards show "Nice work!
   You were in the top 10% of runs this week" / "Congrats! You just set
   your 2nd fastest time." Strava's API doesn't expose a percentile field —
   this needs to be computed against the athlete's own activity history
   (which `stravaGetActivities` already fetches), e.g. "top N% of your own
   runs this week/month" or "Nth fastest on a route with this name." Worth
   scoping as its own small function once you confirm which comparison you
   want.

4. **Style-reference images.** `GenerationStyleCatalog` currently just names
   five placeholder styles with no actual reference art yet. Should those
   ship bundled in the app (simple, but a new style needs an App Store
   release) or live in Cloud Storage/Remote Config (lets you add/rotate
   styles without shipping)?

5. **Selfie/generated-image retention.** Are selfies and generated avatars
   kept in Cloud Storage indefinitely, or deleted after some window? Matters
   for the App Store privacy nutrition label and probably for Strava's API
   agreement.

6. **Does "Regenerate" cost a generation?** Right now `ResultView`'s
   Regenerate button just pops back to the style picker with no metering.
   Should it consume another one of the 3 free generations (and another
   real Gemini call), or be a free retry?

7. **Strava OAuth `state` param.** `stravaOAuthCallback.ts` currently
   trusts the `state` query param as-is as the Firebase UID to write the
   token to. Before wiring up the real `ASWebAuthenticationSession` flow on
   the client, this needs to be a signed, short-lived token minted and
   verified server-side — otherwise anyone could bind an arbitrary UID's
   Strava connection by hitting the callback URL directly.

8. **Token encryption at rest.** Strava access/refresh tokens are currently
   stored as plain Firestore fields. Flagged as a TODO to add Cloud KMS
   envelope encryption before this handles real user tokens.

9. **Brand assets.** `RunFriendBrandMark` (the "run Friends" sunset logo +
   wordmark composited onto every result image) is a hand-drawn SwiftUI
   approximation of the reference branding, not the real asset. Swap it for
   final logo files whenever you have them — same for the character art
   style, which your reference images confirm is photorealistic 3D-render
   (not flat "cartoon"), so `GenerationStyleCatalog`'s style-reference
   images should be produced in that style rather than something like
   comic/pixel/anime as originally scaffolded.

None of these block continuing to build (the mocked scaffold works
end-to-end today) — flagging them now so the real integrations get built
against the right assumptions the first time.
