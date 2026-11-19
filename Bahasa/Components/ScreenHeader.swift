import SwiftUI

/// Serif screen header used in place of the system large title.
struct ScreenHeader: View {
    let indo: String
    let en: String
    var trailing: AnyView?

    init(_ indo: String, _ en: String) {
        self.indo = indo
        self.en = en
        self.trailing = nil
    }

    init<T: View>(_ indo: String, _ en: String, @ViewBuilder trailing: () -> T) {
        self.indo = indo
        self.en = en
        self.trailing = AnyView(trailing())
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(indo)
                    .font(.display(32, .semibold))
                    .foregroundStyle(Theme.ink)
                Text(en)
                    .font(.ui(14))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer(minLength: 8)
            if let trailing {
                trailing
            }
        }
        .padding(.top, 4)
    }
}

/// Streak chip shown on the Learn screen.
struct StreakBadge: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 13, weight: .bold))
            Text("\(days) hari")
                .font(.rounded(13))
        }
        .foregroundStyle(Theme.sambal)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule().fill(Theme.sambal.opacity(0.12)))
    }
}
