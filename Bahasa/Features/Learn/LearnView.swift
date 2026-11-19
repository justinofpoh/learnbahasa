import SwiftUI

struct LearnView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var openLesson: Lesson?
    @State private var paywall: PaywallContext?

    private var greeting: (indo: String, en: String) {
        switch Calendar.current.component(.hour, from: Date()) {
        case ..<11: return ("Selamat pagi", "Good morning")
        case ..<15: return ("Selamat siang", "Good day")
        case ..<18: return ("Selamat sore", "Good afternoon")
        default: return ("Selamat malam", "Good evening. Take it easy.")
        }
    }

    var body: some View {
        NavigationStack {
            CozyPage(title: greeting.indo, subtitle: greeting.en, profile: true) {
                TabArt.learn.view
            } accessory: {
                if progress.streak > 0 {
                    ArtChip(text: "\(progress.streak)", symbol: "flame.fill", tint: Theme.sambal)
                }
            } content: {
                if let next = progress.nextLesson {
                    UpNextCard(unit: next.unit, lesson: next.lesson, goal: progress.goalFraction) {
                        open(next.lesson)
                    }
                } else {
                    AllDoneCard()
                }
                ForEach(Curriculum.units) { unit in
                    UnitSection(unit: unit, nextLessonID: progress.nextLesson?.lesson.id,
                                plus: !Access.lesson(unit.lessons.first?.id ?? "", plan: purchases.plan)) { lesson in
                        open(lesson)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $openLesson) { lesson in
            LessonPlayerView(lesson: lesson, unit: Curriculum.unit(for: lesson.id) ?? Curriculum.unit1)
        }
        .paywall($paywall)
        .onAppear {
            if let id = LaunchArgs.lesson, let lesson = Curriculum.lesson(id) {
                open(lesson)
            }
        }
    }

    private func open(_ lesson: Lesson) {
        if Access.lesson(lesson.id, plan: purchases.plan) {
            openLesson = lesson
        } else if let unit = Curriculum.unit(for: lesson.id) {
            paywall = .unit(unit)
        }
    }
}

private struct UpNextCard: View {
    let unit: Unit
    let lesson: Lesson
    let goal: Double
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.pop()
            action()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        CharacterPortrait(characterID: Cast.tutorID, tint: .white, size: 30)
                        Text("Yuk, lanjut!")
                            .font(.rounded(14, .bold))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    Text(lesson.title)
                        .font(.rounded(24, .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        Text("Start")
                        Image(systemName: "play.fill").font(.system(size: 11, weight: .bold))
                    }
                    .font(.rounded(15, .bold))
                    .foregroundStyle(unit.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(.white))
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle().stroke(.white.opacity(0.25), lineWidth: 7)
                    Circle().trim(from: 0, to: max(0.001, goal))
                        .stroke(.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(Int((goal * 100).rounded()))%")
                            .font(.rounded(15, .heavy))
                        Text("today")
                            .font(.rounded(10, .semibold))
                            .opacity(0.8)
                    }
                    .foregroundStyle(.white)
                }
                .frame(width: 70, height: 70)
            }
            .padding(20)
            .background(CalmSurface(color: unit.color))
        }
        .buttonStyle(.squish)
    }
}

private struct AllDoneCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 24))
            Text("All lessons done. Bagus sekali!")
                .font(.rounded(17, .bold))
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CalmSurface(color: Theme.sawah))
    }
}

private struct UnitSection: View {
    let unit: Unit
    let nextLessonID: String?
    var plus = false
    let open: (Lesson) -> Void

    @EnvironmentObject private var progress: ProgressStore

    private var doneCount: Int { unit.lessons.filter { progress.isDone(lesson: $0.id) }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                UnitBadge(number: unit.number, tint: unit.color, size: 46)
                VStack(alignment: .leading, spacing: 1) {
                    Text(unit.indoTitle)
                        .font(.rounded(19, .bold))
                        .foregroundStyle(Theme.ink)
                    Text(unit.title)
                        .font(.ui(13, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                if plus {
                    ArtChip(text: "Plus", symbol: "sparkles", tint: Theme.sambal)
                } else {
                    Text("\(doneCount)/\(unit.lessons.count)")
                        .font(.rounded(13, .bold))
                        .foregroundStyle(unit.color)
                }
            }
            VStack(spacing: 0) {
                ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                    let done = progress.isDone(lesson: lesson.id)
                    let next = lesson.id == nextLessonID
                    Button {
                        Haptics.select()
                        open(lesson)
                    } label: {
                        CozyRow(title: lesson.title) {
                            StatusDot(state: done ? .done : (next ? .next : .open), tint: unit.color, symbol: next ? "play.fill" : nil)
                        } trailing: {
                            if next {
                                Text("next")
                                    .font(.rounded(12, .bold))
                                    .foregroundStyle(unit.color)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    if index < unit.lessons.count - 1 {
                        Divider().overlay(Theme.line.opacity(0.7)).padding(.leading, 48)
                    }
                }
            }
            .cozyCard(padding: 14)
        }
    }
}
