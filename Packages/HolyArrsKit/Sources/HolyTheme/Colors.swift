import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// An sRGB colour value. Kept separate from `Color` so tokens can be
/// compared against the web's `tokens.css` in tests.
public struct RGBA: Sendable, Hashable {
    public var red: Double, green: Double, blue: Double, alpha: Double

    public init(_ hex: UInt32, alpha: Double = 1) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
        self.alpha = alpha
    }

    public static func white(_ alpha: Double) -> RGBA { RGBA(0xFFFFFF, alpha: alpha) }
    public static func black(_ alpha: Double) -> RGBA { RGBA(0x000000, alpha: alpha) }

    public var hex: UInt32 {
        UInt32((red * 255).rounded()) << 16 | UInt32((green * 255).rounded()) << 8 | UInt32((blue * 255).rounded())
    }
}

/// A token with a light and a dark value, mirroring `:root` and
/// `[data-theme=dark]` in the web app's `lib/core/tokens.css`.
public struct ThemeColor: Sendable, Hashable {
    public let light: RGBA
    public let dark: RGBA

    public init(light: RGBA, dark: RGBA) { self.light = light; self.dark = dark }
    public init(_ both: RGBA) { light = both; dark = both }

    public var color: Color {
        #if canImport(UIKit)
        let (l, d) = (light, dark)
        return Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? d.uiColor : l.uiColor })
        #elseif canImport(AppKit)
        let (l, d) = (light, dark)
        return Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? d.nsColor : l.nsColor
        })
        #endif
    }
}

#if canImport(UIKit)
extension RGBA {
    var uiColor: UIColor { UIColor(red: red, green: green, blue: blue, alpha: alpha) }
}
#elseif canImport(AppKit)
extension RGBA {
    var nsColor: NSColor { NSColor(srgbRed: red, green: green, blue: blue, alpha: alpha) }
}
#endif

/// Colour tokens. Values are copied from HolyArrs 1.2.0 `tokens.css`.
public enum Palette {
    // Surfaces
    public static let bg = ThemeColor(light: RGBA(0xFFFFFF), dark: RGBA(0x0B0B0C))
    public static let sidebarBg = ThemeColor(light: RGBA(0xF6F6F7), dark: RGBA(0x161618))
    public static let surface1 = ThemeColor(light: RGBA(0xFFFFFF), dark: RGBA(0x161618))
    public static let surface2 = ThemeColor(light: RGBA(0xF2F2F4), dark: RGBA(0x1E1E21))
    public static let surface3 = ThemeColor(light: RGBA(0xE9E9EC), dark: RGBA(0x2A2A2E))
    public static let line = ThemeColor(light: .black(0.08), dark: .white(0.09))
    public static let lineStrong = ThemeColor(light: .black(0.16), dark: .white(0.18))
    public static let scrim = ThemeColor(light: .black(0.40), dark: .black(0.60))
    public static let segmentThumb = ThemeColor(light: RGBA(0xFFFFFF), dark: RGBA(0x5A5A5F))

    // Text
    public static let text = ThemeColor(light: RGBA(0x1D1D1F), dark: RGBA(0xF5F5F7))
    public static let textMuted = ThemeColor(light: RGBA(0x6E6E73), dark: RGBA(0xA1A1A6))
    public static let textFaint = ThemeColor(light: RGBA(0x8E8E93), dark: RGBA(0x7C7C80))

    // Brand: red is the only accent.
    public static let accent = ThemeColor(light: RGBA(0xE5352B), dark: RGBA(0xFF453A))
    public static let accentSoft = ThemeColor(light: RGBA(0xE5352B, alpha: 0.10), dark: RGBA(0xFF453A, alpha: 0.16))
    public static let accentText = ThemeColor(light: RGBA(0xCF2C23), dark: RGBA(0xFF453A))
    public static let accentFill = ThemeColor(RGBA(0xD42D24))
    public static let accentFillPressed = ThemeColor(RGBA(0xC42A21))
    public static let textOnRed = ThemeColor(RGBA(0xFFFFFF))

    // Status tones (dots and icons)
    public static let ok = ThemeColor(light: RGBA(0x248A3D), dark: RGBA(0x30D158))
    public static let wait = ThemeColor(light: RGBA(0xB25000), dark: RGBA(0xFFB340))
    public static let fail = ThemeColor(light: RGBA(0xD70015), dark: RGBA(0xFF6961))
    public static let info = ThemeColor(light: RGBA(0x0071E3), dark: RGBA(0x409CFF))
    // Status text (darker in light mode for contrast)
    public static let okText = ThemeColor(light: RGBA(0x1A6E2E), dark: RGBA(0x30D158))
    public static let waitText = ThemeColor(light: RGBA(0x8F4000), dark: RGBA(0xFFB340))
    public static let failText = ThemeColor(light: RGBA(0xB3000F), dark: RGBA(0xFF6961))
    public static let infoText = ThemeColor(light: RGBA(0x0068D1), dark: RGBA(0x409CFF))
    public static let okFill = ThemeColor(RGBA(0x1F7A35))
    public static let okFillPressed = ThemeColor(RGBA(0x1A6E2E))

    // On artwork (same in both themes)
    public static let onArt = ThemeColor(RGBA(0xFFFFFF))
    public static let onArtInk = ThemeColor(RGBA(0x111111))
    public static let onArtSoft = ThemeColor(.white(0.90))
    public static let onArtMuted = ThemeColor(.white(0.84))
    public static let onArtFill = ThemeColor(.white(0.16))
    public static let onArtFillHover = ThemeColor(.white(0.28))
    public static let onArtFillStrong = ThemeColor(.white(0.86))
    public static let onArtRing = ThemeColor(.white(0.22))
    public static let artOK = ThemeColor(RGBA(0x30D158))
    public static let artInfo = ThemeColor(RGBA(0x64B5FF))
    public static let artWait = ThemeColor(RGBA(0xFFB340))
    public static let artFail = ThemeColor(RGBA(0xFF6961))

    // Card corner status circles
    public static let markHave = ThemeColor(RGBA(0x1F9D48))
    public static let markDownloading = ThemeColor(RGBA(0x4F46E5))
    public static let markAsked = ThemeColor(RGBA(0xF0A020))
    public static let markAskedInk = ThemeColor(RGBA(0x2A1A00))
    public static let markDeclined = ThemeColor(RGBA(0xD92D20))
    public static let markInk = ThemeColor(RGBA(0xFFFFFF))
    public static let markRing = ThemeColor(.black(0.22))

    // Toasts are always dark glass.
    public static let toastBg = ThemeColor(RGBA(0x1C1C20, alpha: 0.96))

    /// Ratings star.
    public static let star = ThemeColor(RGBA(0xF5C518))
}

/// SwiftUI access: `Color.holy.accent`, `.foregroundStyle(Color.holy.textMuted)`.
public extension Color {
    enum holy {
        public static var bg: Color { Palette.bg.color }
        public static var surface1: Color { Palette.surface1.color }
        public static var surface2: Color { Palette.surface2.color }
        public static var surface3: Color { Palette.surface3.color }
        public static var line: Color { Palette.line.color }
        public static var lineStrong: Color { Palette.lineStrong.color }
        public static var text: Color { Palette.text.color }
        public static var textMuted: Color { Palette.textMuted.color }
        public static var textFaint: Color { Palette.textFaint.color }
        public static var accent: Color { Palette.accent.color }
        public static var accentSoft: Color { Palette.accentSoft.color }
        public static var accentText: Color { Palette.accentText.color }
        public static var accentFill: Color { Palette.accentFill.color }
        public static var ok: Color { Palette.ok.color }
        public static var wait: Color { Palette.wait.color }
        public static var fail: Color { Palette.fail.color }
        public static var info: Color { Palette.info.color }
    }
}
