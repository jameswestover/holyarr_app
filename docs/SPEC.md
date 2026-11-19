# HolyArrs for iOS — Product & Technical Spec (v1)

Status: draft for review · Target server: HolyArrs 1.2.x · Last updated 2026-11-19

## 1. Summary

A native SwiftUI client for a self-hosted HolyArrs server. It is a **window onto the
server, not a server**: people use it to browse, search, look at a title, and ask for
it. Library management, downloads, Sources, Pick rules, settings and every other admin
surface stay on the web app.

### Decisions so far

| Topic | Decision |
|---|---|
| Audience | Owner + household, distributed via **TestFlight** (no public App Store) |
| Devices | **iPhone + iPad, iOS 17+** |
| Network | **LAN only** — plain `http://<ip>:6262` |
| Media | **Movies and TV shows** (music out of scope for v1) |
| Sign-in | **Plex only** (+ two-factor code if the account has it on) |
| Approvals | **Yes** — simple Approve / Decline for accounts with the `approve` permission |
| Ask sheet | Seasons, **episode-level picking**, **4K toggle**, **quality choice**, **weekly limit display** |
| Extras | **Live status updates** (SSE while foregrounded), **Inbox** |
| Not in v1 | Trailers, music, localisation beyond English UI, push notifications, admin settings |

## 2. Goals and non-goals

**Goals**
- Feel like the HolyArrs web app on a phone: same colours, type, words, status language.
- Asking for a movie or show takes ≤ 3 taps from any poster.
- Request status is always truthful and updates live while the app is open.
- Zero server changes required.

**Non-goals**
- Any server functionality (library, downloads, Sources, Pick rules, subtitles, health).
- Playback. "Ready to watch" deep-links to Plex if installed, otherwise is informational.
- Remote (off-LAN) access, push notifications, App Store distribution.

## 3. Users and permissions

The server is authoritative; the app hides what `GET /api/v1/auth/me` says the person
can't do (`role` ∈ owner/admin/member, `perms[]`).

| Capability | Needs | App behaviour |
|---|---|---|
| Browse / search / title pages | signed in | always |
| Ask for a title | `ask` | Ask button hidden otherwise |
| Asks auto-approve | `auto_approve` (`auto_approve_four_k`) | sheet says "This will start right away" |
| Approve / Decline others | `approve` | "To approve" segment in Requests tab + badge |
| Weekly limits | per-person, n/a for approvers | sheet shows "{left} of {per_week} left this week" |
| Kid accounts | `max_rating` | server filters; app shows what it is given |

Copy follows the web app's role-dependent wording (members see "Ready to watch / Get it /
Requested / You asked · {status}"; staff see "In your Library / Missing / Waiting / Approved
/ Declined / Failed"). Members never see "Failed".

## 4. Information architecture

### iPhone — tab bar (4 tabs)

| Tab | SF Symbol | Content |
|---|---|---|
| **Home** | `house` | `GET /home` rows (asks progress, arrived, new seasons, soon, discover…). Bell (Inbox) and avatar (Account) in the toolbar. |
| **Explore** | `safari` | Movies / Shows / All segmented control → hero carousel + rows from `/explore/head`, infinite rows from `/explore/tail`, genre browse. |
| **Search** | `magnifyingglass` | Typeahead (`/search/suggest`) → results (`/search`). Recent searches stored locally. |
| **Requests** | `tray` (badge) | "Mine" list by state; approvers get a "To approve" segment with pending count badge. |

Active tab: icon tinted accent red, label stays text colour (matches web tab bar).

### iPad — `NavigationSplitView`
Sidebar mirrors the web desktop sidebar (Home, Explore, Search, Requests, Inbox), detail
column holds the same stacks. Poster grids reflow by width (adaptive `GridItem(minimum: 150)`).

### Screens
1. **Connect** — server address field (`192.168.1.20:6262`, optional URL base) → validates with `GET /api/v1/auth/state`, shows server state. Errors in HolyArrs voice ("Couldn't reach HolyArrs at that address. Check it's on and on the same Wi-Fi.").
2. **Sign in with Plex** — single button; two-factor code screen when needed.
3. **Home**, **Explore**, **Genre**, **Row "See all"** — shelves of poster cards.
4. **Search**.
5. **Title page** (movie / show) — hero backdrop, logo or name, meta line, overview, primary Ask/status button, seasons list (shows), cast row, "More like this".
6. **Season detail** — episodes with stills, per-episode availability when in Library.
7. **Ask sheet** — see §6.
8. **Requests** — Mine / To approve; request detail with progress step.
9. **Inbox** — messages, unread badge, mark read on open.
10. **Account** — who you are, server, sign out, appearance (System/Light/Dark), "Open HolyArrs in Safari".

## 5. Design system (ported from `app/frontend/src/lib/core/tokens.css`)

Implemented as a `HolyTheme` Swift module: colour assets with light/dark variants, a
`Font` extension, spacing/radius constants, and reusable views. Names mirror web tokens
so the two can be diffed.

### Colour (light / dark)
| Token | Light | Dark |
|---|---|---|
| bg | `#FFFFFF` | `#0B0B0C` |
| surface1 / 2 / 3 | `#FFFFFF` / `#F2F2F4` / `#E9E9EC` | `#161618` / `#1E1E21` / `#2A2A2E` |
| line / lineStrong | black 8% / 16% | white 9% / 18% |
| text / muted / faint | `#1D1D1F` / `#6E6E73` / `#8E8E93` | `#F5F5F7` / `#A1A1A6` / `#7C7C80` |
| accent (tint) | `#E5352B` | `#FF453A` |
| accentFill (buttons) | `#D42D24` | `#D42D24` |
| ok / wait / fail / info | `#248A3D` / `#B25000` / `#D70015` / `#0071E3` | `#30D158` / `#FFB340` / `#FF6961` / `#409CFF` |
| card corner: have / downloading / asked / declined | `#1F9D48` / `#4F46E5` / `#F0A020` / `#D92D20` | same |

No user-selectable accent — red is the brand. Appearance: System / Light / Dark.

### Type — Geist Variable (bundled, OFL), Dynamic Type–scaled from these base sizes
large-title 700 34 · title1 700 28 · title2 700 22 · title3 600 19 · headline 600 16 ·
body 400 15 · callout 400 14 · subhead 500 13 · footnote 500 12 · caption 600 11.
Tight tracking on titles (−0.02em ≈ `.tracking(-0.6)` at 28pt). Numbers use
`.monospacedDigit()`. Hero title 800 weight, 36–48pt.

### Shape, spacing, motion
- 4pt grid: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64. Gutter 16 (iPhone), 24–40 (iPad).
- Radii: sm 6 · button 10 · card 12 · panel 16 · sheet 20 · pill capsule. Hero 16 (phone) / 24 (iPad).
- Poster 2:3, backdrop 16:9. Card shadow light `0 1 2 / 0 4 12` at 6%; dark adds 1px `line` ring.
- Motion: fast 0.15s, base 0.24s, slow 0.36s; ease-out `(.22,1,.36,1)`; sheets use spring. Press scale 0.97 (buttons) / 0.98 (cards). All respect Reduce Motion.
- Glass: tab bar & toolbars use system `.ultraThinMaterial`; hero buttons white 14% fill + 22% border on material.

### Components (each maps to a web component)
| iOS view | Web source | Notes |
|---|---|---|
| `PosterCard` | `lib/ui/PosterCard.svelte` | radius 12, title 14/600 one line, subtitle footnote muted, corner status circle 28pt top-right, "Fresh" tag bottom-centre |
| `CornerBadge` | `lib/ui/CardBadges.svelte` | have=check, partial=dash, downloading=progress ring, requested=clock, declined=x |
| `StatusPill` / `ArtPill` | `lib/ui/StatusPill.svelte`, `ArtPill.svelte` | 24pt pill, 7pt tone dot; over art → blurred black 55% |
| `Shelf` | rows on Explore/Home | title2 header + "See all", horizontal `LazyHStack`, gap 12 |
| `TitleHero` | `lib/ui/TitleHero.svelte` / `Billboard.svelte` | backdrop at 75% brightness + gradients, logo image or name, primary white button (`#FFF` / `#111`) full width on phone |
| `HolyButton` | `lib/ui/Button.svelte` | lg 44 / md 36 / sm 30; primary accentFill, secondary surface2, destructive fail 12% |
| `AskSheet` | `lib/requests/AskShowDialog.svelte`, `AskParts.svelte` | bottom sheet with grab handle, radius 20 |
| `EmptyState` | `lib/ui/EmptyState.svelte` | 60pt circle icon on surface2, title3, muted body |
| `Toast` | `routes/(frame)/Toast.svelte` | always-dark glass capsule, top of screen |
| `Skeleton` | shimmer | surface2 + 3% accent, 1.6s sweep |

Icons: SF Symbols chosen to match the web's custom stroke set (house, safari, magnifyingglass,
tray, bell, checkmark, xmark, clock, arrow.down.circle, film, tv). App icon from
`static/brand/mark-color.svg` / `apple-touch-icon` source art.

### Voice (from `docs/word-check.md`, `lib/core/i18n/glossary.md`)
- Say **Explore** (never Discover), **Shows / TV shows** (never Series), **Ask for** (verb), **Request(s)** (noun), **Approve / Decline**, **Library**.
- Banned: Monitored, Wanted, Cutoff, Quality Profile, Root Folder, Download Client, Grabbed, Collections, Discover, Series.
- Second person, short, no "please", no exclamation marks. Errors: "Could not load this. Try again."
- English strings ported verbatim from `messages/en/{ui,requests,discover,frame}.json` into a String Catalog so later localisation can reuse the web translations.

## 6. The Ask flow

Entry points: Ask button on a title page; long-press / context menu on any poster
("Ask for {name}"); swipe action in search results.

**Movie:** one tap → if no options apply, ask immediately with optimistic UI and a toast
("Asked for Dune: Part Two"). If 4K or >1 quality exists, show a compact sheet.

**Show:** sheet titled "What would you like?":
- ○ All seasons · ○ Choose seasons or episodes · ○ Future seasons only (44pt rows, selected = accent border + accent-soft fill).
- "Choose" expands to a season list (episode counts; seasons already in Library shown checked & disabled); tapping a season's chevron opens its episodes for per-episode picking.

**Both:** optional 4K toggle (when `four_k.{movie|show}`), quality picker (when
`qualities.{kind}.count > 1`), limit line ("2 of 5 movie asks left this week"; when 0 left:
"You can ask again {relative retry_at}" and disabled button), auto-approve note for
`auto_approve`. Primary button "Ask for {name}".

**Result handling (`POST /api/v1/asks`):**
| Response | UI |
|---|---|
| 201 | toast "Asked for {name}", card corner → requested (or downloading if auto-approved) |
| 200 `joined`/`already` | toast "Someone already asked — you'll hear when it's ready" |
| 409 `{title_id, ready}` | "Already in your Library" |
| 429 `{retry_at}` | limit message, sheet stays |
| 403 | "You can't ask for titles on this account" |

Withdraw: on a waiting ask of mine → "Take back request" (`DELETE /asks/{id}`), confirmation dialog.

**Approvals (approvers only):** "To approve" list (`GET /asks?state=asked`) with poster,
who asked, what (season words), when. Swipe or buttons: Approve (`POST /asks/{id}/approve`,
ok-fill green) / Decline (`POST /asks/{id}/turn-down` with optional note).

## 7. Technical design

### Stack
- Swift 6, SwiftUI, iOS 17 deployment target, Observation (`@Observable`), `NavigationStack` with typed routes, async/await.
- **No third-party dependencies.** Images via a small `ImagePipeline` (URLSession + `URLCache` 200 MB disk + in-memory `NSCache`, downsampling with ImageIO).
- Project generated with **XcodeGen** (`project.yml`) so it can be reviewed as text; logic lives in a local Swift package.

### Modules
```
HolyArrsApp/            App target: scenes, tabs, screens
Packages/HolyArrsKit/
  Sources/HolyAPI/      HTTP client, endpoints, Codable models, SSE client
  Sources/HolyTheme/    tokens, fonts, reusable components
  Sources/HolyFeatures/ view models (Explore, Search, Title, Ask, Requests, Inbox)
  Tests/                decoding fixtures captured from a real 1.2.0 server, VM tests
```

### Networking & auth
- `ServerConfig { baseURL (scheme+host+port+urlBase) }` in `UserDefaults`; one server in v1.
- Dedicated `URLSession` with its own `HTTPCookieStorage`; the `holyarrs_session` cookie rotates hourly via `Set-Cookie`, so storage is persisted. The cookie value is also mirrored to the **Keychain** and restored at launch (cookie storage isn't guaranteed across reinstalls/backups).
- Every non-GET sends `X-CSRF-Token` from `/auth/me` (refetched after any 403 "CSRF" response, then retried once).
- Headers: `X-HolyArrs-Language` = device locale (titles/synopses localised server-side), `User-Agent` containing "iPhone"/"iPad" so the server's Devices list names it.
- **Plex sign-in:** `POST /auth/plex/start` → `{id, auth_url}` (+ pin cookie in our jar) → present `auth_url` in `SFSafariViewController` → poll `POST /auth/plex/finish {id}` every 2 s (server gap is 1 s; PIN lives 10 min) → `202 {waiting:true}` keep polling; 200 → session set, dismiss Safari automatically. If the answer is `{two_factor:true, ticket}` → code screen → `POST /auth/login/two-factor`.
- 401 anywhere → session expired → back to Sign in (server stays remembered).
- `429 Retry-After` (Explore rate limit) → back off and show cached content.

### LAN-only transport
- `Info.plist`: `NSAppTransportSecurity.NSAllowsLocalNetworking = YES` (covers IP addresses and `.local` names over HTTP; no global ATS exception), `NSLocalNetworkUsageDescription` = "HolyArrs connects to your server on your home network."
- The server's host-name guard passes automatically for IP addresses. If someone enters a hostname instead, `auth/state.host_refused` is detected at Connect and explained.
- Off-Wi-Fi: requests fail fast (5 s timeout) → banner "You're not on your home network" with cached content still browsable.

### Images
TMDB URLs (`https://image.tmdb.org/t/p/<size>/<file>`) are rewritten to the server's cached
proxy `/api/v1/artwork/tmdb/{size}/{file}` (cookie-authenticated, works without internet
fallback concerns). Sizes: posters `w342` (phone) / `w500` (iPad), backdrops `w1280`,
stills `w300`, people `w185`. Server-relative picture paths are prefixed with the URL base.

### Live updates
`URLSession.bytes` on `GET {base}/live` while the scene is active; parse SSE, reconnect with
`Last-Event-ID` and the server's `retry: 3000`. Topics consumed: `ask` (upsert my request,
update card corners), `ask_removed`, `title` (availability changes). Stream closes on
background; screens refresh on foreground.

### State & caching
- `AppModel` (session, me, server) injected via `@Environment`.
- `TitleStatusStore`: single source of truth for each title's ask/availability keyed by `tmdb:<id>`, fed by list responses + SSE so every card agrees.
- Last good Home/Explore responses cached on disk (JSON) for instant launch and off-network browsing.

### Endpoints used (all under `{base}/api/v1`)
| Area | Endpoint |
|---|---|
| Connect | `GET /auth/state` |
| Session | `POST /auth/plex/start`, `POST /auth/plex/finish`, `POST /auth/login/two-factor`, `GET /auth/me`, `POST /auth/logout` |
| Home | `GET /home` |
| Explore | `GET /explore/head?type=`, `GET /explore/tail?type=&page=`, `GET /explore/genre-row`, `GET /explore/genre?type=&genre=`, `GET /discover?row=…` (See all) |
| Search | `GET /search/suggest?q=&kind=`, `GET /search?q=` |
| Title | `GET /metadata/{movie\|show}/{tmdb}`, `GET /metadata/show/{tmdb}/seasons/{n}`, `GET /titles/{id}/seasons` (in Library) |
| Ask | `GET /asks/limit`, `POST /asks`, `DELETE /asks/{id}` |
| Requests | `GET /asks?mine=1`, `GET /asks/{id}`, approvers: `GET /asks?state=asked`, `POST /asks/{id}/approve`, `POST /asks/{id}/turn-down` |
| Inbox | `GET /messages`, `POST /messages/read` |
| Live | `GET {base}/live` (SSE, outside `/api/v1`) |
| Art | `GET /artwork/tmdb/{size}/{file}` |

Compatibility: read `GET /openapi.json` in debug builds to diff against the models; decoding
is tolerant (unknown row types / states are skipped or shown generically, never crash).

## 8. Accessibility & quality bar
- Dynamic Type up to AX3 (shelves become vertical lists at accessibility sizes), VoiceOver labels for every card ("Dune, 2021, movie, requested"), 44pt targets, Reduce Motion & Reduce Transparency honoured, contrast per web tokens.
- Cold launch to cached Home < 1 s; poster scroll at 120 Hz on ProMotion.
- No analytics, no third-party network calls; the app only talks to the configured server (and plex.tv inside Safari during sign-in).

## 9. Risks & open items
| Risk | Mitigation |
|---|---|
| API is internal and may change between HolyArrs releases | tolerant decoding, fixture tests per server version, show "Server version not tested" banner when `/openapi.json` diverges |
| Plex PIN tied to client IP + pin cookie | same URLSession for start/finish; Safari only handles plex.tv |
| Session cookie lost (reinstall) | Keychain mirror; worst case one Plex re-sign-in |
| No public version endpoint for members | rely on capability probing, not version numbers |
| Not on LAN | clear offline banner + cached browsing |
| Developing on Linux (no Xcode here) | logic in a Swift package; app built and run by you in Xcode / CI on macOS |
