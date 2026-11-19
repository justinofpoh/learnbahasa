import AVFoundation
import SwiftUI
import UIKit

/// Indonesian text-to-speech. Publishes whatever is being spoken so buttons can animate.
final class Speaker: NSObject, ObservableObject {
    static let shared = Speaker()

    @Published var speakingText: String?

    private let synth = AVSpeechSynthesizer()

    static let normalRate: Float = 0.47
    static let slowRate: Float = 0.32

    private override init() {
        super.init()
        synth.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func say(_ text: String, slow: Bool = false) {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.indonesianVoice
        utterance.rate = slow ? Self.slowRate : ChatPace.current.voiceRate
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.05
        speakingText = text
        synth.speak(utterance)
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
        speakingText = nil
    }

    func isSpeaking(_ text: String) -> Bool { speakingText == text }

    private static let indonesianVoice: AVSpeechSynthesisVoice? = {
        AVSpeechSynthesisVoice(language: "id-ID")
            ?? AVSpeechSynthesisVoice.speechVoices().first { $0.language.hasPrefix("id") }
    }()
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if speakingText == utterance.speechString { speakingText = nil }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if speakingText == utterance.speechString { speakingText = nil }
    }
}

/// Haptic feedback for selection, correct and wrong.
enum Haptics {
    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func correct() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func wrong() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func pop() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

/// `-tab learn|talk|patterns|phrases`, `-lesson <id>`, `-scenario <id>`, `-scene <id>`, `-stage <stage>` for screenshot runs.
enum LaunchArgs {
    static func string(_ key: String) -> String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-" + key), index + 1 < args.count else { return nil }
        let value = args[index + 1]
        return value.hasPrefix("-") ? nil : value
        #else
        return nil
        #endif
    }

    static func flag(_ key: String) -> Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-" + key)
        #else
        return false
        #endif
    }

    /// `-resetRehearsal` clears Scene progress, Your Lines and Recall.
    static var resetRehearsal: Bool { flag("resetRehearsal") }
    /// `-liveDelay <seconds>` shortens the wait before the Live check-in prompt (default 3 h).
    static var liveDelay: Double? { string("liveDelay").flatMap(Double.init) }

    /// Skip splash and onboarding when a screenshot run opens a specific screen.
    static var skipIntro: Bool {
        tab != nil || scene != nil || lesson != nil || scenario != nil || flag("noIntro")
    }
    /// `-onboarding` shows the first-run pages again.
    static var forceOnboarding: Bool = flag("onboarding")

    static var tab: AppTab? { string("tab").flatMap { AppTab(rawValue: $0) } }
    static var lesson: String? { string("lesson") }
    static var scenario: String? { string("scenario") }
    /// `-scene id.warung.lunch` opens a Rehearsal Scene; add `-stage watch|rehearse|perform|live|recall`.
    static var scene: String? { string("scene") }
    static var stage: Stage? { string("stage").flatMap(Stage.init(rawValue:)) }
    /// `-plus` or `-free` pins the plan, so screenshots don't depend on the sandbox account.
    static var forcedPlan: Plan? { flag("plus") ? .plus : (flag("free") ? .free : nil) }
    /// `-paywall` opens the paywall on launch; `-paywallPreview` fills it with sample prices.
    static var paywall: Bool { flag("paywall") }
    static var paywallPreview: Bool { flag("paywallPreview") }
}
