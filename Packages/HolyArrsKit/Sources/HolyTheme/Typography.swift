import SwiftUI

/// The web type scale (`tokens.css`), in Geist, scaled with Dynamic Type.
public enum HolyTextStyle: CaseIterable, Sendable {
    case hero, largeTitle, title1, title2, title3, headline, body, callout, subhead, footnote, caption

    public var size: CGFloat {
        switch self {
        case .hero: 40
        case .largeTitle: 34
        case .title1: 28
        case .title2: 22
        case .title3: 19
        case .headline: 16
        case .body: 15
        case .callout: 14
        case .subhead: 13
        case .footnote: 12
        case .caption: 11
        }
    }

    public var weight: Font.Weight {
        switch self {
        case .hero, .largeTitle, .title1, .title2: .bold
        case .title3, .headline, .caption: .semibold
        case .subhead, .footnote: .medium
        case .body, .callout: .regular
        }
    }

    /// Letter-spacing in em, as on the web.
    public var trackingEm: CGFloat {
        switch self {
        case .hero: -0.03
        case .largeTitle: -0.022
        case .title1: -0.02
        case .title2: -0.018
        case .title3: -0.014
        default: -0.006
        }
    }

    /// The system style this one scales with.
    var relativeTo: Font.TextStyle {
        switch self {
        case .hero, .largeTitle: .largeTitle
        case .title1: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .callout: .callout
        case .subhead: .subheadline
        case .footnote: .footnote
        case .caption: .caption
        }
    }
}

public extension Font {
    /// Geist at a scale step, growing with Dynamic Type.
    static func holy(_ style: HolyTextStyle) -> Font {
        holy(size: style.size, weight: style.weight, relativeTo: style.relativeTo)
    }

    /// Geist at an explicit size (e.g. card titles are 14/600 on the web).
    static func holy(size: CGFloat, weight: Font.Weight = .regular, relativeTo: Font.TextStyle = .body) -> Font {
        HolyFonts.register()
        return .custom(faceName(for: weight), size: size, relativeTo: relativeTo)
    }

    internal static func faceName(for weight: Font.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black: "Geist-Bold"
        case .semibold: "Geist-SemiBold"
        case .medium: "Geist-Medium"
        default: "Geist-Regular"
        }
    }
}

public extension View {
    /// Applies a scale step: font plus the web's tracking.
    func holyText(_ style: HolyTextStyle) -> some View {
        font(.holy(style)).tracking(style.size * style.trackingEm)
    }
}
