# HolyArrs for iOS — Build Plan

Companion to [SPEC.md](SPEC.md). Each milestone ends in a TestFlight-able build.

## M0 — Foundations ✅
- Repo layout: `project.yml` (XcodeGen), `HolyArrsApp/`, `Packages/HolyArrsKit` (HolyAPI, HolyTheme, HolyFeatures), `.gitignore`, README with build steps.
- `HolyTheme`: colour assets (light/dark), bundled Geist Variable, type scale, spacing/radius/motion constants, `HolyButton`, `StatusPill`, `EmptyState`, `Skeleton`, `Toast`.
- App icon from `static/brand` source art.
- GitHub Actions on `macos-latest`: `xcodegen` → build → `swift test` for the package.

## M1 — Connect & sign in
- Connect screen + `GET /auth/state` validation, URL-base support, Local Network permission, `NSAllowsLocalNetworking`.
- `APIClient`: cookie jar persistence + Keychain mirror, CSRF handling, language header, error mapping to HolyArrs-voice messages.
- Plex PIN flow in `SFSafariViewController` with polling; two-factor code screen; `/auth/me` → `AppModel`; sign out.
- **Exit:** sign in on a real device against your server, relaunch stays signed in.

## M2 — Browse
- Models: `ItemView`, `ExploreRowView`, `AskBrief`, Home rows. Fixture JSON captured from your server → decoding tests.
- `ImagePipeline` + artwork URL rewriting.
- `PosterCard` + `CornerBadge`, `Shelf`, hero carousel.
- Home tab, Explore tab (Movies/Shows/All, head + paged tail), genre pages, "See all" grids. iPad split view.
- Disk cache of last Home/Explore; offline banner.

## M3 — Search & title pages
- Search tab: debounced typeahead, results, recent searches.
- Title page (movie/show): hero, meta, overview, cast, More like this; seasons list and season → episodes screen with Library availability.
- `TitleStatusStore` shared across all cards.

## M4 — Asking
- `GET /asks/limit` options; Ask sheet: all / choose seasons & episodes / future only, 4K toggle, quality picker, limit line, auto-approve note.
- Quick ask from poster context menu; optimistic updates; full result handling (201/200/409/429/403).
- Take back a waiting request.

## M5 — Requests, approvals, inbox, live
- Requests tab: Mine grouped by state with progress step; request detail.
- Approvers: "To approve" segment, Approve/Decline (with note), tab badge.
- Inbox list + unread bell badge; mark read.
- SSE `/live` client (foreground only, resume with `Last-Event-ID`) feeding requests + card status.

## M6 — Polish & ship
- Accessibility pass (Dynamic Type AX sizes, VoiceOver, Reduce Motion/Transparency).
- Word check: port the web's banned-words list into a unit test over the String Catalog.
- Performance pass (scroll, image decode), crash-free on bad/unknown JSON.
- TestFlight: bundle ID, signing, internal testers for the household.

## Working constraints
- This cloud session is Linux, with no Xcode or Swift toolchain. I can write all the code, project files and tests here, but compiling, running the simulator and uploading to TestFlight happen on your Mac (or on the macOS GitHub Actions runner from M0).
- To make fixtures I need real responses from your server (see README). A script will collect them while you're signed in on the LAN.
