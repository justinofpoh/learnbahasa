import Foundation
import RevenueCat
import StoreKit
import SwiftUI

/// Product identifiers. They must match App Store Connect, RevenueCat and `Config/Bahasa.storekit`.
/// The paywall itself follows RevenueCat's current offering (its Annual and Monthly packages).
enum ProductIDs {
    static let monthly = "com.justinpoh.bahasa.plus.monthly"
    static let annual = "com.justinpoh.bahasa.plus.annual"
    static let all: [String] = [annual, monthly]
    static let subscriptionGroupName = "Bahasa Plus"
}

enum Plan: String {
    case free, plus
}

/// What each plan can open. Free keeps two full Scenes and the first two Learn units forever.
enum Access {
    static let freeSceneIDs: Set<String> = ["id.warung.lunch", "id.jalan.ojek"]
    static let freeUnitNumbers: Set<Int> = [1, 2]

    static func scene(_ id: String, plan: Plan) -> Bool {
        plan == .plus || freeSceneIDs.contains(id)
    }

    static func lesson(_ id: String, plan: Plan) -> Bool {
        guard plan == .free else { return true }
        guard let unit = Curriculum.unit(for: id) else { return true }
        return freeUnitNumbers.contains(unit.number)
    }
}

/// Purchases and entitlement through RevenueCat (StoreKit 2 underneath). Plus is on while any RevenueCat
/// entitlement is active. The plan is cached so the app opens offline with the right plan.
///
/// API key: `RevenueCatAPIKey` in Info.plist, from the `REVENUECAT_API_KEY` build setting. Debug uses the
/// RevenueCat Test Store key (simulated purchases, no Apple account needed); Release must use the
/// App Store key (`appl_…`) from RevenueCat › Project settings › API keys.
@MainActor
final class PurchaseManager: ObservableObject {
    enum LoadState: Equatable {
        case idle, loading, loaded
        case failed(String)
    }

    enum Outcome: Equatable {
        case success, pending, cancelled
        case failed(String)
    }

    struct SubscriptionStatus: Equatable {
        var productID: String
        var expirationDate: Date?
        var isInTrial: Bool
    }

    private static let cacheKey = "bahasa.plan"

    /// Monthly first in `ProductIDs.all` order: annual, then monthly.
    @Published private(set) var products: [StoreProduct] = []
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var plan: Plan
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var subscription: SubscriptionStatus?

    private let forcedPlan: Plan?
    private var updatesTask: Task<Void, Never>?
    private var packages: [String: Package] = [:]
    private(set) var isConfigured = false

    init() {
        forcedPlan = LaunchArgs.forcedPlan
        let cached = Plan(rawValue: UserDefaults.standard.string(forKey: Self.cacheKey) ?? "") ?? .free
        plan = forcedPlan ?? cached
    }

    var isPlus: Bool { plan == .plus }

    static var apiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String ?? "").trimmingCharacters(in: .whitespaces)
    }

    /// Call once at launch: configures RevenueCat and follows renewals, refunds and Ask to Buy approvals.
    func start() {
        guard !isConfigured else { return }
        let key = Self.apiKey
        guard !key.isEmpty, !key.hasPrefix("$(") else {
            assertionFailure("Set REVENUECAT_API_KEY for this build configuration.")
            loadState = .failed("Purchases aren't set up in this build.")
            return
        }
        #if DEBUG
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(with: Configuration.Builder(withAPIKey: key).with(storeKitVersion: .storeKit2).build())
        isConfigured = true
        guard forcedPlan == nil, updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            for await info in Purchases.shared.customerInfoStream {
                self?.apply(info)
            }
        }
    }

    var monthlyProduct: StoreProduct? { products.first { packages[$0.productIdentifier]?.packageType == .monthly } }
    var annualProduct: StoreProduct? { products.first { packages[$0.productIdentifier]?.packageType == .annual } }

    func isAnnual(_ product: StoreProduct) -> Bool {
        packages[product.productIdentifier]?.packageType == .annual || product.productIdentifier == ProductIDs.annual
    }

    /// Plans come from the current RevenueCat offering (its Monthly and Annual packages).
    func loadProducts() async {
        guard loadState != .loading else { return }
        guard isConfigured else { loadState = .failed("Purchases aren't set up in this build."); return }
        loadState = .loading
        do {
            let offerings = try await Purchases.shared.offerings()
            let available = offerings.current?.availablePackages ?? []
            let chosen = available.filter { $0.packageType == .annual || $0.packageType == .monthly }
            let list = chosen.isEmpty ? available : chosen
            packages = Dictionary(list.map { ($0.storeProduct.productIdentifier, $0) }, uniquingKeysWith: { a, _ in a })
            products = list.map(\.storeProduct).sorted { a, b in
                (packages[a.productIdentifier]?.packageType == .annual ? 0 : 1) < (packages[b.productIdentifier]?.packageType == .annual ? 0 : 1)
            }
            loadState = products.isEmpty ? .failed("Plans aren't available right now.") : .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    func purchase(_ product: StoreProduct) async -> Outcome {
        guard isConfigured else { return .failed("Purchases aren't set up in this build.") }
        purchasingProductID = product.productIdentifier
        defer { purchasingProductID = nil }
        do {
            let result: PurchaseResultData
            if let package = packages[product.productIdentifier] {
                result = try await Purchases.shared.purchase(package: package)
            } else {
                result = try await Purchases.shared.purchase(product: product)
            }
            if result.userCancelled { return .cancelled }
            apply(result.customerInfo)
            return .success
        } catch let error as ErrorCode where error == .paymentPendingError {
            return .pending
        } catch let error as ErrorCode where error == .purchaseCancelledError {
            return .cancelled
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restore() async -> Result<Plan, Error> {
        guard isConfigured else { return .success(plan) }
        do {
            apply(try await Purchases.shared.restorePurchases())
            return .success(plan)
        } catch {
            return .failure(error)
        }
    }

    func refreshEntitlements() async {
        if let forcedPlan {
            plan = forcedPlan
            return
        }
        guard isConfigured, let info = try? await Purchases.shared.customerInfo() else { return }
        apply(info)
    }

    private func apply(_ info: CustomerInfo) {
        if let forcedPlan {
            plan = forcedPlan
            return
        }
        let active = info.entitlements.active.values.sorted { ($0.expirationDate ?? .distantFuture) > ($1.expirationDate ?? .distantFuture) }
        let newPlan: Plan = active.isEmpty ? .free : .plus
        subscription = active.first.map {
            SubscriptionStatus(productID: $0.productIdentifier, expirationDate: $0.expirationDate, isInTrial: $0.periodType == .trial)
        }
        plan = newPlan
        UserDefaults.standard.set(newPlan.rawValue, forKey: Self.cacheKey)
    }

    // MARK: Display helpers, always from live prices

    func monthlyEquivalent(of product: StoreProduct) -> String? {
        guard let period = product.subscriptionPeriod else { return nil }
        let months: Decimal
        switch period.unit {
        case .year: months = Decimal(12 * period.value)
        case .month: months = Decimal(period.value)
        default: return nil
        }
        guard months > 0, let formatter = product.priceFormatter else { return nil }
        return formatter.string(from: NSDecimalNumber(decimal: product.price / months))
    }

    func annualSavingsPercent() -> Int? {
        guard let annual = annualProduct, let monthly = monthlyProduct else { return nil }
        return Self.savingsPercent(monthlyPrice: monthly.price, annualPrice: annual.price)
    }

    nonisolated static func savingsPercent(monthlyPrice: Decimal, annualPrice: Decimal) -> Int? {
        let yearly = monthlyPrice * 12
        guard yearly > 0 else { return nil }
        let percent = NSDecimalNumber(decimal: (yearly - annualPrice) / yearly * 100).doubleValue
        return percent >= 1 ? Int(percent.rounded(.down)) : nil
    }

    nonisolated static func periodDescription(_ period: RevenueCat.SubscriptionPeriod) -> String {
        let unit: String
        switch period.unit {
        case .day: unit = period.value == 1 ? "day" : "days"
        case .week: unit = period.value == 1 ? "week" : "weeks"
        case .month: unit = period.value == 1 ? "month" : "months"
        case .year: unit = period.value == 1 ? "year" : "years"
        @unknown default: unit = "period"
        }
        return period.value == 1 ? unit : "\(period.value) \(unit)"
    }

    /// "7-day free trial" if this account is still eligible.
    func trialDescription(for product: StoreProduct) async -> String? {
        guard isConfigured, let offer = product.introductoryDiscount, offer.paymentMode == .freeTrial else { return nil }
        let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
        guard eligibility == .eligible || eligibility == .unknown else { return nil }
        let p = offer.subscriptionPeriod
        let count = max(1, offer.numberOfPeriods)
        switch p.unit {
        case .day: return "\(p.value * count)-day free trial"
        case .week: return "\(p.value * 7 * count)-day free trial"
        case .month: return "\(p.value * count)-month free trial"
        case .year: return "\(p.value * count)-year free trial"
        @unknown default: return nil
        }
    }
}

/// Where Terms and Privacy live. Terms use Apple's standard licence agreement.
enum LegalLinks {
    static let terms = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacy = URL(string: "https://learnbahasa.app/privacy")!
    static let support = URL(string: "https://learnbahasa.app/support")!
    static let email = "hello@learnbahasa.app"
}
