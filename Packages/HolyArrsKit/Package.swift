// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HolyArrsKit",
    defaultLocalization: "en",
    // macOS is listed only so `swift test` can run on a Mac host in CI.
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "HolyAPI", targets: ["HolyAPI"]),
        .library(name: "HolyTheme", targets: ["HolyTheme"]),
    ],
    targets: [
        .target(name: "HolyAPI"),
        .target(
            name: "HolyTheme",
            resources: [.copy("Resources/Fonts")]
        ),
        .testTarget(name: "HolyAPITests", dependencies: ["HolyAPI"]),
        .testTarget(name: "HolyThemeTests", dependencies: ["HolyTheme"]),
    ],
    swiftLanguageModes: [.v6]
)
