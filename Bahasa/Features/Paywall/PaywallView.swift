import RevenueCat
import StoreKit
import SwiftUI

/// Why the paywall opened. Sets the headline so it always answers "what did I just tap?".
enum PaywallContext: Identifiable {
    case scene(RehearsalScene)
    case unit(Unit)
    case general
    /// Right after the learner finishes their first chat.
    case firstChat(RehearsalScene)

    var id: String {
        switch self {
        case .firstChat(let s): return "first." + s.id
        case .scene(let s): return "scene." + s.id
        case .unit(let u): return "unit." + u.id
        case .general: return "general"
        }
    }

    var headline: String {
        switch self {
        case .firstChat: return "Bagus! You did it."
        case .scene(let s): return "\(s.character.name) is waiting"
        case .unit(let u): return "Unit \(u.number) is in Plus"
        case .general: return "Bahasa Plus"
        }
    }

    var subheadline: String {
        switch self {
        case .firstChat:
            let more = SceneLibrary.scenes.filter { !Access.scene($0.id, plan: .free) }.count
            return "That was a real chat. \(more) more neighbours are ready for the rest of your trip."
        case .scene(let s): return "\(s.titleEn) opens with Bahasa Plus."
        case .unit(let u): return "\(u.indoTitle) and every lesson after it open with Plus."
        case .general: return "Every neighbour, every lesson."
        }
    }

    var focusCharacterID: String? {
        if case .scene(let s) = self { return s.character.id }
        if case .firstChat(let s) = self { return s.character.id }
        return nil
    }
}

/// One plan as the screen shows it. Built from a live RevenueCat `StoreProduct`, or from sample prices in DEBUG previews.
private struct PlanOption: Identifiable, Equatable {
    let id: String
    let title: String
    let price: String
    let period: String
    let perMonth: String?
    let badge: String?
    let trial: String?
    let product: StoreProduct?

    static func == (a: PlanOption, b: PlanOption) -> Bool { a.id == b.id && a.trial == b.trial && a.price == b.price }
}

struct PaywallView: View {
    var context: PaywallContext = .general

    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var options: [PlanOption] = []
    @State private var selectedID: String = ProductIDs.annual
    @State private var busy = false
    @State private var alert: AlertInfo?
    @State private var showManage = false

    private struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        var closesPaywall = false
    }

    private var preview: Bool { LaunchArgs.paywallPreview }
    private var selected: PlanOption? { options.first { $0.id == selectedID } ?? options.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                if purchases.isPlus && !preview {
                    activeCard
                } else {
                    lockedPreview
                    features
                    planSection
                }
                footer
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Theme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if !(purchases.isPlus && !preview) { ctaBar }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.inkSoft)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .accessibilityLabel("Close")
            .padding(.trailing, 16)
            .padding(.top, 12)
        }
        .task { await loadPlans() }
        .onChange(of: purchases.products) { _, _ in Task { await buildOptions() } }
        .alert(item: $alert) { info in
            Alert(title: Text(info.title), message: Text(info.message), dismissButton: .default(Text("OK")) {
                if info.closesPaywall { dismiss() }
            })
        }
        .manageSubscriptionsSheet(isPresented: $showManage)
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 14) {
            NeighboursBand(focusID: context.focusCharacterID)
                .frame(height: 190)
                .padding(.horizontal, -20)
            VStack(spacing: 6) {
                Text(purchases.isPlus && !preview ? "You have Plus" : context.headline)
                    .font(.rounded(30, .heavy))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                Text(purchases.isPlus && !preview ? "Terima kasih! Every neighbour is open." : context.subheadline)
                    .font(.ui(16, .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: Locked chats

    /// The drawings of the chats Plus opens, so it's clear what's waiting.
    private var lockedPreview: some View {
        let locked = SceneLibrary.scenes.filter { !Access.scene($0.id, plan: .free) }
        return VStack(alignment: .leading, spacing: 10) {
            Text("Waiting for you")
                .font(.rounded(17, .bold))
                .foregroundStyle(Theme.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(locked) { scene in
                        VStack(alignment: .leading, spacing: 0) {
                            PlaceIllustration(scene: scene, expression: .happy, compact: true)
                                .frame(width: 150, height: 96)
                                .clipped()
                            VStack(alignment: .leading, spacing: 1) {
                                Text(scene.character.name)
                                    .font(.rounded(14, .bold))
                                    .foregroundStyle(Theme.ink)
                                Text(scene.titleEn)
                                    .font(.ui(11.5))
                                    .foregroundStyle(Theme.inkSoft)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                        }
                        .frame(width: 150)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
        }
    }

    // MARK: Features

    private var features: some View {
        VStack(spacing: 0) {
            FeatureRow(symbol: "map.fill", tint: Theme.sambal,
                       title: "Your whole trip",
                       note: "\(SceneLibrary.scenes.count) chats and \(Curriculum.units.count) stages: warung to temple, ojek to apotek.")
            Divider().overlay(Theme.line.opacity(0.7)).padding(.leading, 58)
            FeatureRow(symbol: "bubble.left.and.bubble.right.fill", tint: Theme.jambu,
                       title: "Every neighbour",
                       note: "Bargain with Bu Ketut, see Mbak Rina at the apotek, fix a tyre with Bli Made.")
            Divider().overlay(Theme.line.opacity(0.7)).padding(.leading, 58)
            FeatureRow(symbol: "book.closed.fill", tint: Theme.indigo,
                       title: "Every lesson",
                       note: "All \(Curriculum.units.count) units, from time words to Bali manners.")
            Divider().overlay(Theme.line.opacity(0.7)).padding(.leading, 58)
            FeatureRow(symbol: "sparkles", tint: Theme.sawah,
                       title: "New places as they open",
                       note: "More chats arrive with updates, at no extra cost.")
        }
        .cozyCard(padding: 14)
        .overlay(alignment: .bottom) {
            Text("Ibu Wayan and Pak Agus stay free, always.")
                .font(.ui(13, .medium))
                .foregroundStyle(Theme.inkSoft)
                .offset(y: 28)
        }
        .padding(.bottom, 22)
    }

    // MARK: Plans

    @ViewBuilder
    private var planSection: some View {
        if options.isEmpty {
            VStack(spacing: 12) {
                switch purchases.loadState {
                case .failed:
                    Text("Plans couldn't load. Check your connection.")
                        .font(.ui(15, .medium))
                        .foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                    Button("Try again") { Task { await purchases.loadProducts() } }
                        .font(.rounded(16, .bold))
                        .foregroundStyle(Theme.sambal)
                default:
                    ProgressView().tint(Theme.sambal)
                        .frame(height: 140)
                }
            }
            .frame(maxWidth: .infinity)
            .cozyCard()
        } else {
            VStack(spacing: 12) {
                ForEach(options) { option in
                    PlanCard(option: option, selected: option.id == selected?.id) {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { selectedID = option.id }
                    }
                }
                disclosure
            }
        }
    }

    /// Guideline 3.1.2: title, length, price, auto-renewal and how to cancel, next to the button.
    private var disclosure: some View {
        Group {
            if let plan = selected {
                Text(disclosureText(for: plan))
            }
        }
        .font(.ui(12))
        .foregroundStyle(Theme.inkSoft)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 6)
    }

    private func disclosureText(for plan: PlanOption) -> String {
        let start = plan.trial.map { "After the \($0), " } ?? ""
        let charge = "\(ProductIDs.subscriptionGroupName) (\(plan.title)) is \(plan.price) per \(plan.period)"
        return "\(start)\(start.isEmpty ? charge : charge.prefix(1).lowercased() + charge.dropFirst()), charged to your Apple Account. It renews automatically unless you cancel at least 24 hours before the end of the period. Manage or cancel any time in Settings › Apple Account › Subscriptions."
    }

    // MARK: Active

    private var activeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Theme.sawah)
                VStack(alignment: .leading, spacing: 2) {
                    Text(activeTitle)
                        .font(.rounded(17, .bold))
                        .foregroundStyle(Theme.ink)
                    if let note = activeNote {
                        Text(note)
                            .font(.ui(13))
                            .foregroundStyle(Theme.inkSoft)
                    }
                }
            }
            ChunkyButton(title: "Manage subscription", color: Theme.indigo) { showManage = true }
        }
        .cozyCard()
    }

    private var activeTitle: String {
        guard let sub = purchases.subscription else { return ProductIDs.subscriptionGroupName }
        let kind = sub.productID == ProductIDs.annual ? "Yearly" : "Monthly"
        return sub.isInTrial ? "\(kind) plan · free trial" : "\(kind) plan"
    }

    private var activeNote: String? {
        guard let date = purchases.subscription?.expirationDate else { return nil }
        let when = date.formatted(date: .abbreviated, time: .omitted)
        return purchases.subscription?.isInTrial == true ? "Trial ends \(when)" : "Renews \(when)"
    }

    // MARK: CTA

    private var ctaBar: some View {
        VStack(spacing: 8) {
            Button {
                Task { await buy() }
            } label: {
                if busy {
                    ProgressView().tint(.white)
                } else {
                    Text(ctaTitle)
                }
            }
            .buttonStyle(ChunkyButtonStyle(color: selected == nil ? Theme.inkSoft.opacity(0.35) : Theme.sambal))
            .disabled(selected == nil || busy)
            if let trial = selected?.trial {
                Text("\(trial.capitalizedFirst), then \(selected?.price ?? "")/\(selected?.period ?? "")")
                    .font(.ui(12, .medium))
                    .foregroundStyle(Theme.inkSoft)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Rectangle().fill(Theme.paper).shadow(color: Theme.ink.opacity(0.06), radius: 10, y: -4).ignoresSafeArea())
    }

    private var ctaTitle: String {
        guard let plan = selected else { return "Continue" }
        if plan.trial != nil { return "Start free trial" }
        return "Subscribe for \(plan.price)"
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 18) {
            Button("Restore") { Task { await restore() } }
            Button("Terms") { openURL(LegalLinks.terms) }
            Button("Privacy") { openURL(LegalLinks.privacy) }
        }
        .font(.ui(13, .semibold))
        .foregroundStyle(Theme.inkSoft)
        .disabled(busy)
    }

    // MARK: Actions

    private func loadPlans() async {
        if preview {
            options = Self.sampleOptions
            return
        }
        if purchases.products.isEmpty { await purchases.loadProducts() }
        await buildOptions()
    }

    private func buildOptions() async {
        guard !preview else { return }
        var built: [PlanOption] = []
        let savings = purchases.annualSavingsPercent()
        for product in purchases.products {
            guard let period = product.subscriptionPeriod else { continue }
            let annual = purchases.isAnnual(product)
            built.append(PlanOption(
                id: product.productIdentifier,
                title: annual ? "Yearly" : "Monthly",
                price: product.localizedPriceString,
                period: PurchaseManager.periodDescription(period),
                perMonth: annual ? purchases.monthlyEquivalent(of: product).map { "\($0)/month" } : nil,
                badge: annual ? savings.map { "Save \($0)%" } : nil,
                trial: await purchases.trialDescription(for: product),
                product: product))
        }
        options = built
        if !built.contains(where: { $0.id == selectedID }), let first = built.first { selectedID = first.id }
    }

    private func buy() async {
        guard let plan = selected else { return }
        guard let product = plan.product else {
            Haptics.correct()   // DEBUG preview: nothing to buy
            return
        }
        busy = true
        defer { busy = false }
        switch await purchases.purchase(product) {
        case .success:
            Haptics.correct()
            alert = AlertInfo(title: "Selamat datang!", message: "Bahasa Plus is on. Every neighbour is waiting.", closesPaywall: true)
        case .pending:
            alert = AlertInfo(title: "Waiting for approval", message: "Plus opens as soon as the purchase is approved.")
        case .cancelled:
            break
        case .failed(let message):
            Haptics.wrong()
            alert = AlertInfo(title: "Purchase didn't go through", message: message)
        }
    }

    private func restore() async {
        busy = true
        defer { busy = false }
        switch await purchases.restore() {
        case .success(.plus):
            Haptics.correct()
            alert = AlertInfo(title: "Restored", message: "Bahasa Plus is back on.", closesPaywall: true)
        case .success:
            alert = AlertInfo(title: "Nothing to restore", message: "This Apple Account has no active Bahasa Plus subscription.")
        case .failure(let error):
            alert = AlertInfo(title: "Couldn't restore", message: error.localizedDescription)
        }
    }

    /// DEBUG `-paywallPreview` only, so the simulator shows real-looking plans without the StoreKit config.
    private static let sampleOptions: [PlanOption] = [
        PlanOption(id: ProductIDs.annual, title: "Yearly", price: "$59.99", period: "year", perMonth: "$5.00/month",
                   badge: "Save 49%", trial: "7-day free trial", product: nil),
        PlanOption(id: ProductIDs.monthly, title: "Monthly", price: "$9.99", period: "month", perMonth: nil,
                   badge: nil, trial: nil, product: nil)
    ]
}

private extension String {
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}

// MARK: - Pieces

private struct FeatureRow: View {
    let symbol: String
    let tint: Color
    let title: String
    let note: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(tint.opacity(0.13)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.rounded(16, .bold))
                    .foregroundStyle(Theme.ink)
                Text(note)
                    .font(.ui(13))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }
}

private struct PlanCard: View {
    let option: PlanOption
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().stroke(selected ? Theme.sambal : Theme.line, lineWidth: 2.5)
                    if selected {
                        Circle().fill(Theme.sambal).padding(5)
                    }
                }
                .frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(option.title)
                            .font(.rounded(18, .heavy))
                            .foregroundStyle(Theme.ink)
                        if let badge = option.badge {
                            Text(badge)
                                .font(.rounded(11, .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Theme.sawah))
                        }
                    }
                    Text(option.trial.map { "\($0.capitalizedFirst), then \(option.price)/\(option.period)" }
                         ?? "\(option.price) every \(option.period)")
                        .font(.ui(13, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 1) {
                    Text(option.perMonth?.replacingOccurrences(of: "/month", with: "") ?? option.price)
                        .font(.rounded(18, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text("/month")
                        .font(.ui(11, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selected ? Theme.sambal.opacity(0.07) : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? Theme.sambal : Theme.line, lineWidth: selected ? 2 : 1)
            )
            .scaleEffect(selected ? 1 : 0.98)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// The paywall's drawing: everyone in a row on a sambal kawung band, the Plus neighbours waving.
private struct NeighboursBand: View {
    var focusID: String?

    private var cast: [(id: String, tint: Color, free: Bool)] {
        let free = SceneLibrary.scenes.filter { Access.freeSceneIDs.contains($0.id) }
        let plus = SceneLibrary.scenes.filter { !Access.freeSceneIDs.contains($0.id) }
        var list = (free + plus.prefix(4)).map { (id: $0.character.id, tint: $0.color, free: Access.freeSceneIDs.contains($0.id)) }
        if let focusID, !list.contains(where: { $0.id == focusID }),
           let s = SceneLibrary.scenes.first(where: { $0.character.id == focusID }) {
            list[list.count - 1] = (id: s.character.id, tint: s.color, free: false)
        }
        return list
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.sambal.lighter(0.08), Theme.sambal.darker(0.04)], startPoint: .top, endPoint: .bottom)
            KawungPattern(color: .white, opacity: 0.1, cell: 54)
            VStack(spacing: 14) {
                Text("Ayo ngobrol!")
                    .font(.rounded(17, .heavy))
                    .foregroundStyle(Theme.sambal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(ChatShape(mine: false).fill(Theme.card))
                HStack(spacing: -10) {
                    ForEach(cast, id: \.id) { member in
                        let focus = member.id == focusID
                        CharacterPortrait(characterID: member.id, tint: member.free ? .white : member.tint,
                                          size: focus ? 82 : 64, speaking: focus,
                                          expression: .happy, animated: focus || !member.free)
                            .zIndex(focus ? 1 : 0)
                    }
                }
            }
            .padding(.top, 24)
        }
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32, style: .continuous))
    }
}

// MARK: - Presenting

extension View {
    /// Shows the paywall for whatever context is set; clears it on close.
    func paywall(_ context: Binding<PaywallContext?>) -> some View {
        sheet(item: context) { ctx in
            PaywallView(context: ctx)
        }
    }
}

/// A tiny sambal sparkle that marks Plus content. Never a padlock: nothing here is "forbidden", it's just extra.
struct PlusBadge: View {
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(Theme.sambal))
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .accessibilityLabel("Bahasa Plus")
    }
}
