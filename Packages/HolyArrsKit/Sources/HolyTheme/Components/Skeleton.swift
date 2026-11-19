import SwiftUI

/// A loading placeholder block: surface-2 tinted 3% with the accent and a
/// 1.6s shimmer sweep (static under Reduce Motion).
public struct SkeletonBlock: View {
    var cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = Radius.card) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Palette.surface2.color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Palette.accent.color.opacity(0.03))
            )
            .shimmer()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .accessibilityLabel("Loading")
    }
}

private struct Shimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content.overlay {
            if !reduceMotion {
                GeometryReader { geo in
                    let w = geo.size.width
                    LinearGradient(
                        colors: [.clear, .white.opacity(scheme == .dark ? 0.06 : 0.45), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: w * 0.6)
                    .offset(x: phase * w * 1.6)
                }
                .onAppear {
                    withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) { phase = 1 }
                }
                .allowsHitTesting(false)
            }
        }
    }
}

public extension View {
    /// Adds the loading shimmer sweep.
    func shimmer() -> some View { modifier(Shimmer()) }
}
