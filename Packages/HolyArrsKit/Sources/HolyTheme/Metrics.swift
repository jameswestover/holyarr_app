import SwiftUI

/// The 4pt spacing scale.
public enum Space {
    public static let x1: CGFloat = 4
    public static let x2: CGFloat = 8
    public static let x3: CGFloat = 12
    public static let x4: CGFloat = 16
    public static let x5: CGFloat = 20
    public static let x6: CGFloat = 24
    public static let x8: CGFloat = 32
    public static let x10: CGFloat = 40
    public static let x12: CGFloat = 48
    public static let x16: CGFloat = 64

    /// Page side gutter: 16 on phones, larger on wide layouts.
    public static func gutter(compact: Bool) -> CGFloat { compact ? 16 : 32 }
    /// Gap between cards in a shelf.
    public static func shelfGap(compact: Bool) -> CGFloat { compact ? 12 : 16 }
    /// Minimum tap target.
    public static let tapTarget: CGFloat = 44
}

public enum Radius {
    public static let small: CGFloat = 6
    public static let button: CGFloat = 10
    public static let card: CGFloat = 12
    public static let panel: CGFloat = 16
    public static let sheet: CGFloat = 20
    public static func hero(compact: Bool) -> CGFloat { compact ? 16 : 24 }
}

public enum AspectRatio {
    public static let poster: CGFloat = 2.0 / 3.0
    public static let wide: CGFloat = 16.0 / 9.0
}

/// Motion tokens. Use through `Motion.animation(_:reduceMotion:)` so that
/// Reduce Motion turns them off, as the web does.
public enum Motion {
    public enum Speed: Sendable {
        case instant, fast, base, slow, page, glide

        public var seconds: Double {
            switch self {
            case .instant: 0.09
            case .fast: 0.15
            case .base: 0.24
            case .slow: 0.36
            case .page: 0.30
            case .glide: 0.42
            }
        }
    }

    /// `cubic-bezier(.22, 1, .36, 1)`
    public static func easeOut(_ speed: Speed = .base) -> Animation {
        .timingCurve(0.22, 1, 0.36, 1, duration: speed.seconds)
    }

    /// `cubic-bezier(.65, 0, .35, 1)`
    public static func easeInOut(_ speed: Speed = .base) -> Animation {
        .timingCurve(0.65, 0, 0.35, 1, duration: speed.seconds)
    }

    /// Sheets and toasts.
    public static let spring = Animation.spring(response: 0.42, dampingFraction: 0.82)

    public static func animation(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }

    public static let pressScaleButton: CGFloat = 0.97
    public static let pressScaleCard: CGFloat = 0.98
    public static let pressScaleRound: CGFloat = 0.92
}

// MARK: - Elevation

public enum Elevation: Sendable {
    case card, lift, modal
}

private struct ElevationModifier: ViewModifier {
    let level: Elevation
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        let dark = scheme == .dark
        let (a1, r1, y1, a2, r2, y2): (Double, CGFloat, CGFloat, Double, CGFloat, CGFloat) = switch level {
        case .card: dark ? (0.30, 2, 1, 0.28, 12, 4) : (0.06, 2, 1, 0.06, 12, 4)
        case .lift: dark ? (0.34, 4, 2, 0.44, 28, 12) : (0.08, 4, 2, 0.14, 28, 12)
        case .modal: dark ? (0, 0, 0, 0.56, 64, 24) : (0, 0, 0, 0.24, 64, 24)
        }
        content
            .shadow(color: .black.opacity(a1), radius: r1 / 2, y: y1)
            .shadow(color: .black.opacity(a2), radius: r2 / 2, y: y2)
            // Dark mode adds a 1px line ring to every shadow.
            .overlay {
                if dark {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Palette.line.color, lineWidth: 1)
                        .allowsHitTesting(false)
                }
            }
    }
}

public extension View {
    func elevation(_ level: Elevation, cornerRadius: CGFloat = Radius.card) -> some View {
        modifier(ElevationModifier(level: level, cornerRadius: cornerRadius))
    }
}
