import Foundation
import UserNotifications

/// Gentle local notifications: one daily practice nudge from a neighbour, and a heads-up the day
/// before a free trial turns into a paid subscription. Nothing leaves the phone.
@MainActor
final class Reminders: ObservableObject {
    static let shared = Reminders()

    private static let dailyID = "bahasa.daily"
    private static let trialID = "bahasa.trial-ends"
    static let enabledKey = "bahasa.reminder.on"
    static let hourKey = "bahasa.reminder.hour"
    static let minuteKey = "bahasa.reminder.minute"
    static let askedKey = "bahasa.reminder.asked"

    @Published private(set) var authorized = false

    private let center = UNUserNotificationCenter.current()

    var isOn: Bool { UserDefaults.standard.bool(forKey: Self.enabledKey) }
    var time: DateComponents {
        let d = UserDefaults.standard
        let hour = d.object(forKey: Self.hourKey) as? Int ?? 19
        let minute = d.object(forKey: Self.minuteKey) as? Int ?? 0
        return DateComponents(hour: hour, minute: minute)
    }

    func refreshStatus() async {
        let settings = await center.notificationSettings()
        authorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    /// Asks once (after the learner has done something worth coming back for) and turns the daily nudge on.
    @discardableResult
    func enable() async -> Bool {
        UserDefaults.standard.set(true, forKey: Self.askedKey)
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        await refreshStatus()
        UserDefaults.standard.set(granted, forKey: Self.enabledKey)
        if granted { scheduleDaily() }
        return granted
    }

    func disable() {
        UserDefaults.standard.set(false, forKey: Self.enabledKey)
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyID])
    }

    func setTime(hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: Self.hourKey)
        UserDefaults.standard.set(minute, forKey: Self.minuteKey)
        if isOn { scheduleDaily() }
    }

    /// One repeating notification at the chosen time. The text rotates by weekday so it never feels canned.
    func scheduleDaily(streak: Int = 0) {
        guard isOn else { return }
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyID])
        let weekday = Calendar.current.component(.weekday, from: Date())
        let line = Self.nudges[(weekday + streak) % Self.nudges.count]
        let content = UNMutableNotificationContent()
        content.title = line.title
        content.body = streak > 1 ? "\(line.body) Keep your \(streak)-day streak going." : line.body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        center.add(UNNotificationRequest(identifier: Self.dailyID, content: content, trigger: trigger))
    }

    /// A day before a free trial ends, so nobody is surprised by a charge.
    func scheduleTrialEnding(on end: Date?, planName: String) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.trialID])
        guard let end, authorized else { return }
        let fire = end.addingTimeInterval(-24 * 60 * 60)
        guard fire > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Your free trial ends tomorrow"
        content.body = "\(planName) starts tomorrow. To cancel, open Settings › your name › Subscriptions today."
        content.sound = .default
        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
        center.add(UNNotificationRequest(identifier: Self.trialID, content: content,
                                         trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)))
    }

    private static let nudges: [(title: String, body: String)] = [
        ("Ibu Wayan is waiting", "Five minutes at the warung? Nasi campurnya enak hari ini."),
        ("Pak Agus is outside", "Hop on for a quick ride. Mau ke mana?"),
        ("Kak Dewi has a word for you", "One short lesson, then you're done for today."),
        ("Bu Ketut saved you a sarong", "A little haggling practice keeps the numbers fresh."),
        ("Putu wants to ngopi", "A quick chat over coffee? Sudah makan?"),
        ("Selamat sore!", "Just five minutes keeps your Indonesian warm."),
        ("Ayo ngobrol!", "Your neighbours miss you. One chat, five minutes."),
    ]
}
