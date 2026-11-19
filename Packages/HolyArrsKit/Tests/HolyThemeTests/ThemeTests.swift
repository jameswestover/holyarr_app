import CoreText
import SwiftUI
import Testing
@testable import HolyTheme

/// Pins tokens to HolyArrs 1.2.0 `app/frontend/src/lib/core/tokens.css`.
/// If the web changes a value, update both on purpose.
@Suite struct TokenTests {
    @Test(arguments: [
        (Palette.bg, 0xFFFFFF, 0x0B0B0C),
        (Palette.surface1, 0xFFFFFF, 0x161618),
        (Palette.surface2, 0xF2F2F4, 0x1E1E21),
        (Palette.surface3, 0xE9E9EC, 0x2A2A2E),
        (Palette.text, 0x1D1D1F, 0xF5F5F7),
        (Palette.textMuted, 0x6E6E73, 0xA1A1A6),
        (Palette.textFaint, 0x8E8E93, 0x7C7C80),
        (Palette.accent, 0xE5352B, 0xFF453A),
        (Palette.accentText, 0xCF2C23, 0xFF453A),
        (Palette.accentFill, 0xD42D24, 0xD42D24),
        (Palette.ok, 0x248A3D, 0x30D158),
        (Palette.wait, 0xB25000, 0xFFB340),
        (Palette.fail, 0xD70015, 0xFF6961),
        (Palette.info, 0x0071E3, 0x409CFF),
    ] as [(ThemeColor, UInt32, UInt32)])
    func colorsMatchWeb(token: ThemeColor, light: UInt32, dark: UInt32) {
        #expect(token.light.hex == light)
        #expect(token.dark.hex == dark)
        #expect(token.light.alpha == 1 && token.dark.alpha == 1)
    }

    @Test func linesAreTranslucent() {
        #expect(Palette.line.light == .black(0.08))
        #expect(Palette.line.dark == .white(0.09))
        #expect(Palette.lineStrong.light == .black(0.16))
        #expect(Palette.lineStrong.dark == .white(0.18))
    }

    @Test func cornerMarks() {
        #expect(Palette.markHave.light.hex == 0x1F9D48)
        #expect(Palette.markDownloading.light.hex == 0x4F46E5)
        #expect(Palette.markAsked.light.hex == 0xF0A020)
        #expect(Palette.markDeclined.light.hex == 0xD92D20)
    }

    @Test func hexRoundTrips() {
        #expect(RGBA(0x123456).hex == 0x123456)
    }

    @Test func typeScaleMatchesWeb() {
        let expected: [TextStyle: CGFloat] = [
            .largeTitle: 34, .title1: 28, .title2: 22, .title3: 19, .headline: 16,
            .body: 15, .callout: 14, .subhead: 13, .footnote: 12, .caption: 11,
        ]
        for (style, size) in expected { #expect(style.size == size) }
        #expect(TextStyle.title1.weight == .bold)
        #expect(TextStyle.caption.weight == .semibold)
    }

    @Test func spacingIsOnFourPointGrid() {
        for s in [Space.x1, Space.x2, Space.x3, Space.x4, Space.x5, Space.x6, Space.x8, Space.x10, Space.x12, Space.x16] {
            #expect(s.truncatingRemainder(dividingBy: 4) == 0)
        }
    }

    @Test func statusTonesMatchWeb() {
        #expect(TitleStatus.inLibrary.tone == .ok)
        #expect(TitleStatus.downloading.tone == .info)
        #expect(TitleStatus.missing.tone == .wait)
        #expect(TitleStatus.requested.tone == .idle)
        #expect(TitleStatus.approved.tone == .ok)
        #expect(TitleStatus.turnedDown.tone == .idle)
        #expect(TitleStatus.failed.tone == .fail)
        #expect(TitleStatus.comingSoon.tone == .idle)
    }
}

@Suite struct FontTests {
    @Test func allFacesAreBundled() {
        let names = Set(HolyFonts.fontURLs.map { $0.deletingPathExtension().lastPathComponent })
        #expect(names == Set(HolyFonts.faces))
    }

    @Test(arguments: HolyFonts.faces)
    func faceRegisters(name: String) {
        HolyFonts.register()
        let font = CTFontCreateWithName(name as CFString, 12, nil)
        #expect(CTFontCopyPostScriptName(font) as String == name)
    }

    @Test func weightsMapToFaces() {
        #expect(Font.faceName(for: .regular) == "Geist-Regular")
        #expect(Font.faceName(for: .medium) == "Geist-Medium")
        #expect(Font.faceName(for: .semibold) == "Geist-SemiBold")
        #expect(Font.faceName(for: .bold) == "Geist-Bold")
        #expect(Font.faceName(for: .heavy) == "Geist-Bold")
    }
}
