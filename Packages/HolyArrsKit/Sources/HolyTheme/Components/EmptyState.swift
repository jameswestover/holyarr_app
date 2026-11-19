import SwiftUI

/// Centred empty or error state (`lib/ui/EmptyState.svelte`).
public struct EmptyState<Actions: View>: View {
    let systemImage: String
    let title: String
    let message: String?
    let actions: Actions

    public init(
        systemImage: String,
        title: String,
        message: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: Space.x3) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.textMuted.color)
                .frame(width: 60, height: 60)
                .background(Palette.surface2.color, in: Circle())
                .padding(.bottom, Space.x1)
                .accessibilityHidden(true)
            Text(title)
                .holyText(.title3)
                .foregroundStyle(Palette.text.color)
            if let message {
                Text(message)
                    .holyText(.body)
                    .foregroundStyle(Palette.textMuted.color)
            }
            actions.padding(.top, Space.x2)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 460)
        .padding(.vertical, Space.x12)
        .padding(.horizontal, Space.x6)
        .frame(maxWidth: .infinity)
    }
}

public extension EmptyState where Actions == EmptyView {
    init(systemImage: String, title: String, message: String? = nil) {
        self.init(systemImage: systemImage, title: title, message: message) { EmptyView() }
    }
}
