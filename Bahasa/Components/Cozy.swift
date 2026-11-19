import SwiftUI

// The one page structure every tab and Scene uses: a drawing across the top, then a soft
// paper sheet with a title and evenly spaced sections. Nothing floats; everything sits on the sheet.

struct CozyPage<Art: View, Accessory: View, Content: View>: View {
    let title: String
    var subtitle: String?
    var artHeight: CGFloat = 230
    /// Keep the accessory fixed while scrolling (for close buttons). Otherwise it scrolls with the art.
    var pinned: Bool = false
    /// Shows the learner's profile button in the top-right corner (every tab has it).
    var profile: Bool = false
    @ViewBuilder var art: () -> Art
    @ViewBuilder var accessory: () -> Accessory
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    art()
                        .frame(height: artHeight + geo.safeAreaInsets.top)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(alignment: .topTrailing) {
                            if !pinned {
                                corner
                                    .padding(.horizontal, 16)
                                    .padding(.top, geo.safeAreaInsets.top + 6)
                            }
                        }
                    VStack(alignment: .leading, spacing: 26) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.rounded(32, .heavy))
                                .foregroundStyle(Theme.ink)
                            if let subtitle {
                                Text(subtitle)
                                    .font(.ui(15, .medium))
                                    .foregroundStyle(Theme.inkSoft)
                            }
                        }
                        content()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 26)
                    .padding(.bottom, 120)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30, style: .continuous)
                            .fill(Theme.paper)
                            .shadow(color: Theme.ink.opacity(0.07), radius: 14, y: -4)
                    )
                    .offset(y: -30)
                    .padding(.bottom, -30)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .topTrailing) {
                if pinned {
                    corner
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                }
            }
        }
        .background(Theme.paper.ignoresSafeArea())
    }

    private var corner: some View {
        HStack(spacing: 8) {
            accessory()
            if profile { ProfileButton() }
        }
    }
}

extension CozyPage where Accessory == EmptyView {
    init(title: String, subtitle: String? = nil, artHeight: CGFloat = 230, profile: Bool = false,
         @ViewBuilder art: @escaping () -> Art, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.artHeight = artHeight
        self.profile = profile
        self.art = art
        self.accessory = { EmptyView() }
        self.content = content
    }
}

/// A section on a page: a short rounded heading, then its content.
struct CozySection<Trailing: View, Content: View>: View {
    let title: String
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.rounded(19, .bold))
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 8)
                trailing()
            }
            content()
        }
    }
}

extension CozySection where Trailing == EmptyView {
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.trailing = { EmptyView() }
        self.content = content
    }
}

/// Soft card: warm white, round corners, a gentle shadow instead of a hard outline.
struct CozyCard: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = 22

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Theme.card)
                    .shadow(color: Theme.kopi.opacity(0.08), radius: 10, y: 4)
            )
    }
}

extension View {
    func cozyCard(padding: CGFloat = 16, radius: CGFloat = 22) -> some View {
        modifier(CozyCard(padding: padding, radius: radius))
    }
}

/// A small chip that sits on top of artwork (streaks, stars, counts).
struct ArtChip: View {
    let text: String
    var symbol: String?
    var tint: Color = Theme.ink

    var body: some View {
        HStack(spacing: 5) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 12, weight: .bold))
            }
            Text(text).font(.rounded(13, .bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(Capsule().fill(.ultraThinMaterial))
    }
}

/// One list row inside a card: leading badge, title, optional note, trailing accessory.
struct CozyRow<Leading: View, Trailing: View>: View {
    let title: String
    var note: String?
    @ViewBuilder var leading: () -> Leading
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 14) {
            leading()
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.rounded(16, .semibold))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                if let note {
                    Text(note)
                        .font(.ui(13))
                        .foregroundStyle(Theme.inkSoft)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

/// Status dot used in rows: done ✓, next (filled ring), or open.
struct StatusDot: View {
    enum State { case done, next, open }
    let state: State
    let tint: Color
    var symbol: String?

    var body: some View {
        ZStack {
            Circle().fill(state == .done ? tint : (state == .next ? tint.opacity(0.15) : Theme.line.opacity(0.6)))
            Image(systemName: state == .done ? "checkmark" : (symbol ?? "circle.fill"))
                .font(.system(size: state == .done ? 13 : (symbol == nil ? 6 : 13), weight: .bold))
                .foregroundStyle(state == .done ? .white : (state == .next ? tint : Theme.inkSoft.opacity(0.7)))
        }
        .frame(width: 34, height: 34)
    }
}

/// A quiet coloured surface: soft gradient and a faint, still kawung. No motion, no noise.
struct CalmSurface: View {
    var color: Color
    var radius: CGFloat = 24

    var body: some View {
        ZStack {
            LinearGradient(colors: [color.lighter(0.06), color.darker(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
            KawungPattern(color: .white, opacity: 0.08, cell: 60)
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}
