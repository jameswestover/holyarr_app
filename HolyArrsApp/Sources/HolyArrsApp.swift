import HolyTheme
import SwiftUI

@main
struct HolyArrsApp: App {
    @State private var toasts = ToastCenter()
    @AppStorage(Appearance.storageKey) private var appearance: Appearance = .system

    init() {
        HolyFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(toasts)
                .toastHost(toasts)
                .tint(Palette.accent.color)
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}

/// Light / Dark / System, like the web's theme setting.
enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark

    static let storageKey = "holyarrs-theme"

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
