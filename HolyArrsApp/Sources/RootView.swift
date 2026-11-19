import HolyTheme
import SwiftUI

/// The four tabs from the spec. Screens arrive in M1–M5; for now each tab
/// shows a placeholder, and debug builds can open the design catalogue.
struct RootView: View {
    enum Tab: Hashable, CaseIterable {
        case home, explore, search, requests

        var title: String {
            switch self {
            case .home: "Home"
            case .explore: "Explore"
            case .search: "Search"
            case .requests: "Requests"
            }
        }

        var systemImage: String {
            switch self {
            case .home: "house"
            case .explore: "safari"
            case .search: "magnifyingglass"
            case .requests: "tray"
            }
        }
    }

    @State private var tab: Tab = .home

    var body: some View {
        TabView(selection: $tab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationStack {
                    PlaceholderScreen(tab: tab)
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                .tag(tab)
            }
        }
    }
}

private struct PlaceholderScreen: View {
    let tab: RootView.Tab
    @State private var showCatalog = false

    #if DEBUG
    static let showsCatalog = true
    #else
    static let showsCatalog = false
    #endif

    var body: some View {
        ScrollView {
            EmptyState(
                systemImage: tab.systemImage,
                title: tab.title,
                message: "This screen is on its way."
            )
        }
        .background(Palette.bg.color)
        .navigationTitle(tab.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if Self.showsCatalog {
                    Button("Design", systemImage: "paintpalette") { showCatalog = true }
                }
            }
        }
        .sheet(isPresented: $showCatalog) {
            NavigationStack { DesignCatalogView() }
        }
    }
}

#Preview {
    RootView()
        .environment(ToastCenter())
}
