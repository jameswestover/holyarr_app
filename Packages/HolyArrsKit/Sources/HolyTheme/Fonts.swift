import CoreText
import Foundation

/// Registers the bundled Geist faces (SIL OFL 1.1, see Fonts/Geist-OFL.txt).
///
/// Only static weights are bundled. The web hero uses weight 800; iOS uses
/// Bold (700) there, because Geist has no static 800 roman face.
public enum HolyFonts {
    /// PostScript names of the bundled faces.
    public static let faces = ["Geist-Regular", "Geist-Medium", "Geist-SemiBold", "Geist-Bold"]

    /// Call once at launch. Safe to call repeatedly.
    public static func register() { _ = registered }

    /// The font files found in the bundle (exposed for tests).
    public static var fontURLs: [URL] {
        Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") ?? []
    }

    private static let registered: Void = {
        for url in fontURLs {
            // Already-registered errors are harmless (previews, tests).
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()
}
