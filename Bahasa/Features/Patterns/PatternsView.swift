import SwiftUI

struct PatternsView: View {
    var body: some View {
        NavigationStack {
            CozyPage(title: "Pola", subtitle: "How sentences fit together", profile: true) {
                TabArt.patterns.view
            } content: {
                RoleLegend()
                ForEach(Curriculum.units) { unit in
                    let entries = Curriculum.patternEntries.filter { $0.unit.id == unit.id }
                    if !entries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                UnitBadge(number: unit.number, tint: unit.color, size: 36)
                                Text(unit.indoTitle)
                                    .font(.rounded(19, .bold))
                                    .foregroundStyle(Theme.ink)
                            }
                            VStack(spacing: 0) {
                                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                    NavigationLink {
                                        PatternDetailView(entry: entry)
                                    } label: {
                                        CozyRow(title: entry.concept.title) {
                                            Circle().fill(unit.color).frame(width: 9, height: 9).frame(width: 20)
                                        } trailing: {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(Theme.inkSoft.opacity(0.4))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    if index < entries.count - 1 {
                                        Divider().overlay(Theme.line.opacity(0.7)).padding(.leading, 34)
                                    }
                                }
                            }
                            .cozyCard(padding: 14)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

/// The word colours, on one line you can swipe.
private struct RoleLegend: View {
    private let roles: [Role] = [.subject, .verb, .object, .time, .helper, .negation, .describe, .question, .link]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(roles) { role in
                    HStack(spacing: 6) {
                        Circle().fill(role.color).frame(width: 8, height: 8)
                        Text(role.label)
                            .font(.rounded(13, .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(role.color.opacity(0.12)))
                }
            }
        }
        .scrollClipDisabled()
    }
}

struct PatternDetailView: View {
    let entry: PatternEntry

    var body: some View {
        ScrollView {
            ConceptStepView(concept: entry.concept, tint: entry.unit.color)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 32)
        }
        .background(Theme.paper)
        .navigationTitle(entry.unit.indoTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
