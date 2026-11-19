# HolyArrs for iOS

A native iPhone & iPad client for a self-hosted [HolyArrs](https://github.com/HolyArrs/HolyArrs) server: browse, search, and ask for movies and TV shows, and track your requests. Approvers can also approve or decline requests. Everything else stays on the server's web app.

- [Product & technical spec](docs/SPEC.md)
- [Build plan](docs/PLAN.md)

Status: **M0 (foundations)**. The app shell has placeholder tabs, and debug builds include a design catalogue (the paint-palette button in the top bar).

## Layout

```
project.yml                 XcodeGen spec (the .xcodeproj is generated, not committed)
Config/App.xcconfig         bundle ID / team defaults; override in Config/Signing.local.xcconfig
HolyArrsApp/                app target: entry point, tabs, design catalogue, assets
Packages/HolyArrsKit/
  Sources/HolyAPI/          server address, networking (grows from M1)
  Sources/HolyTheme/        tokens from the web's tokens.css, Geist font, components
  Tests/                    swift-testing suites
.github/workflows/ios.yml   CI: package tests + simulator build on macOS
```

## Build

Requirements: Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
```

```bash
xcodegen generate && open HolyArrs.xcodeproj
```

To sign for your devices or TestFlight, create `Config/Signing.local.xcconfig` (it's git-ignored):

```
PRODUCT_BUNDLE_IDENTIFIER = com.yourname.holyarrs
DEVELOPMENT_TEAM = ABCDE12345
```

Run the package tests without Xcode's UI:

```bash
swift test --package-path Packages/HolyArrsKit
```

## Credits

- Design tokens, wording and the HolyArrs mark come from the [HolyArrs](https://github.com/HolyArrs/HolyArrs) web app (AGPL-3.0).
- [Geist](https://vercel.com/font) by Vercel, under the SIL Open Font License 1.1 (`Packages/HolyArrsKit/Sources/HolyTheme/Resources/Fonts/Geist-OFL.txt`).
