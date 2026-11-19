import SwiftUI

/// Buttons from the web's `lib/ui/Button.svelte` and `ActionButton.svelte`.
///
///     Button("Ask for Dune") { … }.buttonStyle(.holy(.primary, size: .large, fullWidth: true))
public struct HolyButtonStyle: ButtonStyle {
    public enum Variant: CaseIterable, Sendable {
        /// Red fill, the main action.
        case primary
        /// Grey surface fill.
        case secondary
        /// Text only, accent coloured.
        case plain
        /// Red text on a faint red fill.
        case destructive
        /// Green fill (Approve).
        case approve
        /// White pill on artwork (title page main action).
        case hero
        /// Frosted pill on artwork (title page secondary actions).
        case heroGlass
    }

    public enum Size: CaseIterable, Sendable {
        case large, medium, small

        var height: CGFloat {
            switch self {
            case .large: 44
            case .medium: 36
            case .small: 30
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .large: 15
            case .medium: 14
            case .small: 13
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .large: 20
            case .medium: 16
            case .small: 12
            }
        }
    }

    public var variant: Variant
    public var size: Size
    public var fullWidth: Bool

    public init(_ variant: Variant = .primary, size: Size = .medium, fullWidth: Bool = false) {
        self.variant = variant
        self.size = size
        self.fullWidth = fullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, style: self)
    }

    private struct StyledButton: View {
        let configuration: ButtonStyleConfiguration
        let style: HolyButtonStyle
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.colorScheme) private var scheme
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            let pressed = configuration.isPressed
            configuration.label
                .font(.holy(size: style.size.fontSize, weight: .semibold))
                .lineLimit(1)
                .foregroundStyle(foreground)
                .padding(.horizontal, style.size.horizontalPadding)
                .frame(minHeight: style.size.height)
                .frame(maxWidth: style.fullWidth ? .infinity : nil)
                .background(background(pressed: pressed), in: shape)
                .overlay {
                    if style.variant == .heroGlass {
                        shape.strokeBorder(Palette.onArtRing.color, lineWidth: 1)
                    }
                }
                .shadow(color: style.variant == .hero ? .black.opacity(0.22) : .clear, radius: 10, y: 6)
                .contentShape(shape)
                .scaleEffect(pressed && !reduceMotion ? pressScale : 1)
                .opacity(isEnabled ? 1 : (scheme == .dark ? 0.55 : 0.6))
                .animation(Motion.animation(Motion.easeOut(.fast), reduceMotion: reduceMotion), value: pressed)
        }

        private var isPill: Bool { style.variant == .hero || style.variant == .heroGlass }

        private var pressScale: CGFloat { isPill ? Motion.pressScaleRound : Motion.pressScaleButton }

        private var shape: some InsettableShape {
            RoundedRectangle(
                cornerRadius: isPill ? style.size.height / 2 : (style.size == .small ? 8 : Radius.button),
                style: .continuous
            )
        }

        private var foreground: Color {
            switch style.variant {
            case .primary, .approve: Palette.textOnRed.color
            case .secondary: Palette.text.color
            case .plain: Palette.accentText.color
            case .destructive: Palette.failText.color
            case .hero: Palette.onArtInk.color
            case .heroGlass: Palette.onArt.color
            }
        }

        private func background(pressed: Bool) -> AnyShapeStyle {
            switch style.variant {
            case .primary: AnyShapeStyle((pressed ? Palette.accentFillPressed : Palette.accentFill).color)
            case .secondary: AnyShapeStyle((pressed ? Palette.surface3 : Palette.surface2).color)
            case .plain: AnyShapeStyle(pressed ? Palette.accentSoft.color : .clear)
            case .destructive: AnyShapeStyle(Palette.fail.color.opacity(pressed ? 0.18 : 0.12))
            case .approve: AnyShapeStyle((pressed ? Palette.okFillPressed : Palette.okFill).color)
            case .hero: AnyShapeStyle(Color.white.opacity(pressed ? 0.86 : 1))
            case .heroGlass: AnyShapeStyle((pressed ? Palette.onArtFillHover : Palette.onArtFill).color)
            }
        }
    }
}

public extension ButtonStyle where Self == HolyButtonStyle {
    static func holy(
        _ variant: HolyButtonStyle.Variant = .primary,
        size: HolyButtonStyle.Size = .medium,
        fullWidth: Bool = false
    ) -> HolyButtonStyle {
        HolyButtonStyle(variant, size: size, fullWidth: fullWidth)
    }
}
