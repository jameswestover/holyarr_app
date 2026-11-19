import Observation
import SwiftUI

/// A short message in an always-dark glass capsule at the top of the screen
/// (`routes/(frame)/Toast.svelte`).
public struct Toast: Identifiable {
    public struct Action {
        public let title: String
        public let perform: @MainActor () -> Void

        public init(_ title: String, perform: @escaping @MainActor () -> Void) {
            self.title = title
            self.perform = perform
        }
    }

    public let id = UUID()
    public var title: String
    public var message: String?
    public var systemImage: String?
    public var tone: StatusTone?
    public var action: Action?

    public init(
        _ title: String,
        message: String? = nil,
        systemImage: String? = nil,
        tone: StatusTone? = nil,
        action: Action? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.tone = tone
        self.action = action
    }
}

/// Shows one toast at a time; a new one replaces the current one.
@MainActor @Observable
public final class ToastCenter {
    public private(set) var current: Toast?
    private var dismissTask: Task<Void, Never>?

    public init() {}

    public func show(_ toast: Toast, for seconds: Double = 4) {
        current = toast
        dismissTask?.cancel()
        let id = toast.id
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled, self?.current?.id == id else { return }
            self?.dismiss()
        }
    }

    public func dismiss() {
        dismissTask?.cancel()
        current = nil
    }
}

private struct ToastView: View {
    let toast: Toast
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: Space.x3) {
            if let systemImage = toast.systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(toast.tone?.onArt ?? Palette.onArt.color)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.holy(size: 14.5, weight: .semibold, relativeTo: .subheadline))
                    .foregroundStyle(.white)
                if let message = toast.message {
                    Text(message)
                        .font(.holy(.subhead))
                        .foregroundStyle(.white.opacity(0.62))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let action = toast.action {
                Button(action.title) {
                    action.perform()
                    dismiss()
                }
                .font(.holy(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(minHeight: 30)
                .background(.white.opacity(0.14), in: Capsule())
            }
        }
        .padding(.horizontal, Space.x5)
        .padding(.vertical, Space.x2)
        .frame(minHeight: 58)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Capsule(style: .continuous).fill(Palette.toastBg.color))
        }
        .environment(\.colorScheme, .dark)
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .frame(maxWidth: 480)
        .padding(.horizontal, Space.x4)
        .gesture(DragGesture(minimumDistance: 10).onEnded { if $0.translation.height < 0 { dismiss() } })
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

private struct ToastHost: ViewModifier {
    let center: ToastCenter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            ZStack {
                if let toast = center.current {
                    ToastView(toast: toast) { center.dismiss() }
                        .id(toast.id)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, Space.x2)
            .animation(reduceMotion ? .easeOut(duration: 0.15) : Motion.spring, value: center.current?.id)
        }
    }
}

public extension View {
    /// Shows `center`'s toasts over this view. Attach once near the root.
    func toastHost(_ center: ToastCenter) -> some View {
        modifier(ToastHost(center: center))
    }
}
