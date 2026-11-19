import HolyTheme
import SwiftUI

/// Every theme token and component on one page, the counterpart of the web's
/// `/dev/ui`. Use it to compare against the web app side by side.
struct DesignCatalogView: View {
    @Environment(ToastCenter.self) private var toasts
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Appearance.storageKey) private var appearance: Appearance = .system

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.x8) {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                brand
                section("Type") { typeScale }
                section("Colours") { colours }
                section("Buttons") { buttons }
                section("Status") { statuses }
                section("On artwork") { onArtwork }
                section("Loading") { loading }
                section("Empty state") {
                    EmptyState(systemImage: "tray", title: "No requests yet", message: "Titles you ask for show up here.") {
                        Button("Explore") {}.buttonStyle(.holy(.secondary))
                    }
                    .background(Palette.surface1.color, in: RoundedRectangle(cornerRadius: Radius.panel))
                    .elevation(.card, cornerRadius: Radius.panel)
                }
                section("Toast") {
                    HStack {
                        Button("Show toast") {
                            toasts.show(Toast("Asked for Dune: Part Two", message: "You'll hear when it's ready.",
                                              systemImage: "checkmark.circle.fill", tone: .ok,
                                              action: .init("Undo") {}))
                        }
                        .buttonStyle(.holy(.secondary))
                    }
                }
            }
            .padding(Space.gutter(compact: true))
        }
        .background(Palette.bg.color)
        .navigationTitle("Design")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
        }
    }

    private var brand: some View {
        HStack(spacing: Space.x3) {
            Image("BrandMark").resizable().frame(width: 28, height: 28)
            Text("HolyArrs")
                .font(.holy(size: 17, weight: .semibold))
                .tracking(-0.34)
                .foregroundStyle(Palette.text.color)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Text(title).holyText(.title2).foregroundStyle(Palette.text.color)
            content()
        }
    }

    private var typeScale: some View {
        VStack(alignment: .leading, spacing: Space.x2) {
            ForEach(TextStyle.allCases, id: \.self) { style in
                Text("\(String(describing: style)) · \(Int(style.size))")
                    .holyText(style)
                    .foregroundStyle(Palette.text.color)
            }
        }
    }

    private var colours: some View {
        let swatches: [(String, ThemeColor)] = [
            ("bg", Palette.bg), ("surface1", Palette.surface1), ("surface2", Palette.surface2),
            ("surface3", Palette.surface3), ("text", Palette.text), ("muted", Palette.textMuted),
            ("faint", Palette.textFaint), ("accent", Palette.accent), ("accentFill", Palette.accentFill),
            ("ok", Palette.ok), ("wait", Palette.wait), ("fail", Palette.fail), ("info", Palette.info),
            ("have", Palette.markHave), ("downloading", Palette.markDownloading),
            ("asked", Palette.markAsked), ("declined", Palette.markDeclined),
        ]
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: Space.x3)], spacing: Space.x3) {
            ForEach(swatches.indices, id: \.self) { i in
                let (name, token) = swatches[i]
                VStack(alignment: .leading, spacing: Space.x1) {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(token.color)
                        .frame(height: 44)
                        .overlay(RoundedRectangle(cornerRadius: Radius.small).strokeBorder(Palette.line.color))
                    Text(name).font(.holy(.footnote)).foregroundStyle(Palette.textMuted.color)
                }
            }
        }
    }

    private var buttons: some View {
        VStack(alignment: .leading, spacing: Space.x3) {
            Button("Ask for Dune") {}.buttonStyle(.holy(.primary, size: .large, fullWidth: true))
            HStack {
                Button("Secondary") {}.buttonStyle(.holy(.secondary))
                Button("Plain") {}.buttonStyle(.holy(.plain))
                Button("Decline") {}.buttonStyle(.holy(.destructive))
            }
            HStack {
                Button("Approve") {}.buttonStyle(.holy(.approve, size: .small))
                Button("Small") {}.buttonStyle(.holy(.secondary, size: .small))
                Button("Disabled") {}.buttonStyle(.holy(.primary, size: .small)).disabled(true)
            }
        }
    }

    private var statuses: some View {
        FlowLayout(spacing: Space.x2) {
            ForEach(TitleStatus.allCases, id: \.self) { StatusPill($0) }
        }
    }

    private var onArtwork: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(red: 0.35, green: 0.22, blue: 0.12), Color(red: 0.08, green: 0.1, blue: 0.2)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: Space.x3) {
                HStack(spacing: Space.x2) {
                    StatusPill(.inLibrary, overArt: true)
                    StatusPill(.downloading, label: "Downloading 42%", overArt: true)
                    StatusPill(.requested, label: "Requested", overArt: true)
                }
                Text("Dune: Part Two")
                    .holyText(.hero)
                    .foregroundStyle(.white)
                HStack {
                    Button("Ask for it", systemImage: "plus") {}.buttonStyle(.holy(.hero, size: .large))
                    Button("Trailer", systemImage: "play.fill") {}.buttonStyle(.holy(.heroGlass, size: .large))
                }
            }
            .padding(Space.x5)
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: Radius.hero(compact: true), style: .continuous))
    }

    private var loading: some View {
        HStack(spacing: Space.x3) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: Space.x2) {
                    SkeletonBlock().aspectRatio(AspectRatio.poster, contentMode: .fit)
                    SkeletonBlock(cornerRadius: 4).frame(height: 12)
                    SkeletonBlock(cornerRadius: 4).frame(width: 50, height: 10)
                }
            }
        }
    }
}

/// Wraps children onto new lines (for pill rows).
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(width: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (point, subview) in zip(arrange(width: bounds.width, subviews: subviews).points, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> (points: [CGPoint], size: CGSize) {
        var points: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return (points, CGSize(width: maxX, height: y + rowHeight))
    }
}

#Preview {
    NavigationStack { DesignCatalogView() }
        .environment(ToastCenter())
}
