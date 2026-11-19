import AVFoundation
import SwiftUI
import UIKit

/// Indonesian voices. Plays the bundled Supertonic recording for a line when there is one (the same
/// recordings as learnbahasa.app), otherwise falls back to the system id-ID voice.
/// Publishes whatever is being spoken so buttons can animate.
final class Speaker: NSObject, ObservableObject {
    static let shared = Speaker()

    @Published var speakingText: String?

    private let synth = AVSpeechSynthesizer()
    private var player: AVAudioPlayer?

    static let normalRate: Float = 0.47
    static let slowRate: Float = 0.32

    private override init() {
        super.init()
        synth.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    /// `voice` is who is speaking: a character id ("ibu-wayan"), "learner" or "tutor" (the default).
    func say(_ text: String, slow: Bool = false, voice: String = "tutor") {
        stopAll()
        speakingText = text
        let rate = slow ? Self.slowRate : ChatPace.current.voiceRate
        if let url = VoiceBank.shared.recording(for: text, voice: voice),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.delegate = self
            player.enableRate = true
            // Recordings are already a touch slower than natural speech; scale them with the chosen pace.
            player.rate = slow ? 0.72 : max(0.75, min(1.25, rate / Self.normalRate))
            player.prepareToPlay()
            self.player = player
            if player.play() { return }
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.indonesianVoice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.05
        synth.speak(utterance)
    }

    func stop() {
        stopAll()
        speakingText = nil
    }

    private func stopAll() {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        player?.stop()
        player = nil
    }

    func isSpeaking(_ text: String) -> Bool { speakingText == text }

    private static let indonesianVoice: AVSpeechSynthesisVoice? = {
        AVSpeechSynthesisVoice(language: "id-ID")
            ?? AVSpeechSynthesisVoice.speechVoices().first { $0.language.hasPrefix("id") }
    }()
}

extension Speaker: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            guard player === self.player else { return }
            self.player = nil
            self.speakingText = nil
        }
    }
}

/// Index of the bundled recordings (`Voices/voices.json`: "voice|text" → file id), written by
/// tools/voice/make_audio.py. Lines are matched the way the script wrote them.
final class VoiceBank {
    static let shared = VoiceBank()

    private let byKey: [String: String]
    private let byText: [String: String]

    private init() {
        let url = Bundle.main.url(forResource: "voices", withExtension: "json")
            ?? Bundle.main.url(forResource: "voices", withExtension: "json", subdirectory: "Voices")
        let index = url.flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode([String: String].self, from: $0) } ?? [:]
        byKey = index
        var text: [String: String] = [:]
        // Any voice will do when the asked-for one has no recording; prefer the tutor's.
        for (key, id) in index.sorted(by: { $0.key.hasPrefix("tutor|") && !$1.key.hasPrefix("tutor|") }) {
            guard let bar = key.firstIndex(of: "|") else { continue }
            let line = String(key[key.index(after: bar)...])
            if text[line] == nil { text[line] = id }
        }
        byText = text
    }

    static func normalize(_ text: String) -> String {
        text.replacingOccurrences(of: "…", with: "")
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    func recording(for text: String, voice: String) -> URL? {
        let line = Self.normalize(text)
        guard let id = byKey["\(voice)|\(line)"] ?? byText[line] else { return nil }
        return Bundle.main.url(forResource: id, withExtension: "mp3")
            ?? Bundle.main.url(forResource: id, withExtension: "mp3", subdirectory: "Voices")
    }
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
