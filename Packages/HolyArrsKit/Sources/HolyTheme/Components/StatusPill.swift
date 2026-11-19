import SwiftUI

/// A title's status, as in the web's `lib/ui/StatusPill.svelte`.
public enum TitleStatus: CaseIterable, Sendable {
    case inLibrary, downloading, missing, requested, approved, turnedDown, failed, comingSoon

    public var tone: StatusTone {
        switch self {
        case .inLibrary, .approved: .ok
        case .downloading: .info
        case .missing: .wait
        case .failed: .fail
        case .requested, .turnedDown, .comingSoon: .idle
        }
    }

    /// SF Symbol standing in for the web's glyph.
    public var systemImage: String {
        switch self {
        case .inLibrary: "checkmark"
        case .downloading: "arrow.down"
        case .missing: "circle.lefthalf.filled"
        case .requested, .approved: "clock"
        case .turnedDown: "xmark"
        case .failed: "exclamationmark.triangle"
        case .comingSoon: "calendar"
        }
    }

    /// Staff wording from `messages/en/ui.json`. Member wording arrives with
    /// the request screens; members never see "Failed".
    public var staffLabel: String {
        switch self {
        case .inLibrary: "In your Library"
        case .downloading: "Downloading"
        case .missing: "Missing"
        case .requested: "Waiting"
        case .approved: "Approved"
        case .turnedDown: "Declined"
        case .failed: "Failed"
        case .comingSoon: "Coming soon"
        }
    }
}

public enum StatusTone: CaseIterable, Sendable {
    case ok, info, wait, fail, idle

    var dot: Color {
        switch self {
        case .ok: Palette.ok.color
        case .info: Palette.info.color
        case .wait: Palette.wait.color
        case .fail: Palette.fail.color
        case .idle: Palette.textFaint.color
        }
    }

    /// Only ok and fail colour the label text, as on the web.
    var text: Color {
        switch self {
        case .ok: Palette.okText.color
        case .fail: Palette.failText.color
        default: Palette.text.color
        }
    }

    var onArt: Color {
        switch self {
        case .ok: Palette.artOK.color
        case .info: Palette.artInfo.color
        case .wait: Palette.artWait.color
        case .fail: Palette.artFail.color
        case .idle: Palette.onArtSoft.color
        }
    }
}

/// A 24pt pill with a tone dot. Pass `overArt: true` on artwork to get the
/// web's ArtPill (dark frosted, coloured glyph).
public struct StatusPill: View {
    let label: String
    let tone: StatusTone
    let systemImage: String?
    let overArt: Bool

    public init(_ label: String, tone: StatusTone, systemImage: String? = nil, overArt: Bool = false) {
        self.label = label
        self.tone = tone
        self.systemImage = systemImage
        self.overArt = overArt
    }

    public init(_ status: TitleStatus, label: String? = nil, overArt: Bool = false) {
        self.init(label ?? status.staffLabel, tone: status.tone, systemImage: status.systemImage, overArt: overArt)
    }

    public var body: some View {
        if overArt { artPill } else { pill }
    }

    private var pill: some View {
        HStack(spacing: 6) {
            Circle().fill(tone.dot).frame(width: 7, height: 7)
            Text(label)
                .font(.holy(.subhead))
                .foregroundStyle(tone.text)
                .lineLimit(1)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .frame(minHeight: 24)
        .background(Palette.surface2.color, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var artPill: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(tone.onArt)
            }
            Text(label)
                .font(.holy(.caption))
                .foregroundStyle(Palette.onArt.color)
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .frame(minHeight: 26)
        .background {
            Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().fill(Color.black.opacity(0.55)))
        }
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
    }
}
