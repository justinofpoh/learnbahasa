import Foundation

/// How fast chats run: the pauses between lines and the voice speed. Chosen in a chat's header
/// or in Profile; read fresh at every pause so a change applies straight away.
enum ChatPace: String, CaseIterable, Identifiable {
    case relaxed, normal, local

    static let storageKey = "bahasa.chatPace"
    static let waitKey = "bahasa.waitForMe"

    var id: String { rawValue }

    static var current: ChatPace {
        UserDefaults.standard.string(forKey: storageKey).flatMap(ChatPace.init(rawValue:)) ?? .normal
    }

    /// When on, a listening chat stops after each line until the learner taps Next.
    static var waitForMe: Bool { UserDefaults.standard.bool(forKey: waitKey) }

    /// Multiplies every pause in a chat.
    var pauseScale: Double {
        switch self {
        case .relaxed: return 1.7
        case .normal: return 1.0
        case .local: return 0.7
        }
    }

    /// AVSpeechUtterance rate for normal playback. The tortoise button stays at `Speaker.slowRate`.
    var voiceRate: Float {
        switch self {
        case .relaxed: return 0.40
        case .normal: return 0.47
        case .local: return 0.52
        }
    }

    var title: String {
        switch self {
        case .relaxed: return "Relaxed"
        case .normal: return "Normal"
        case .local: return "Like a local"
        }
    }

    var symbol: String {
        switch self {
        case .relaxed: return "tortoise.fill"
        case .normal: return "figure.walk"
        case .local: return "hare.fill"
        }
    }

    var note: String {
        switch self {
        case .relaxed: return "Slower voice, longer pauses"
        case .normal: return "A calm, clear pace"
        case .local: return "Closer to real speed"
        }
    }
}
