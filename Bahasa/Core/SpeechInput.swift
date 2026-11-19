import AVFoundation
import Speech
import SwiftUI

/// On-device-preferred speech recognition for Perform (spec §9.6).
/// Streams partial results into `transcript`; the caller matches the final text.
@MainActor
final class SpeechInput: ObservableObject {
    @Published var transcript = ""
    @Published var listening = false
    @Published var unavailable: String?

    private let recognizer: SFSpeechRecognizer?
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    init(locale: String = "id-ID") {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
    }

    func toggle() {
        listening ? stop() : start()
    }

    func start() {
        // On-device only: replies never leave the phone.
        guard let recognizer, recognizer.isAvailable, recognizer.supportsOnDeviceRecognition else {
            unavailable = "Speaking needs Indonesian on-device dictation, which this device doesn't have. Typing works just as well."
            return
        }
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                guard status == .authorized else {
                    self.unavailable = "Allow speech recognition in Settings to speak your replies."
                    return
                }
                AVAudioApplication.requestRecordPermission { granted in
                    Task { @MainActor in
                        guard granted else {
                            self.unavailable = "Allow the microphone in Settings to speak your replies."
                            return
                        }
                        self.begin()
                    }
                }
            }
        }
    }

    private func begin() {
        guard let recognizer else { return }
        Speaker.shared.stop()
        transcript = ""
        unavailable = nil
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            unavailable = "Couldn't start the microphone."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true
        self.request = request

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else {
            unavailable = "No microphone input available."
            return
        }
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        engine.prepare()
        do { try engine.start() } catch {
            unavailable = "Couldn't start the microphone."
            return
        }
        listening = true
        Haptics.tap()

        task = recognizer.recognitionTask(with: request) { result, error in
            Task { @MainActor in
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal { self.stop() }
                }
                if error != nil { self.stop() }
            }
        }
    }

    func stop() {
        guard listening else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        listening = false
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
