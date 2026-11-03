import Combine
import SwiftUI
import TypingTutorCore

struct PracticeScreen<ResultActions: View>: View {
    @ObservedObject var session: ExerciseSession
    let title: String
    let blurb: String
    let onBack: () -> Void
    let result: () -> ResultActions

    init(
        session: ExerciseSession,
        title: String,
        blurb: String,
        onBack: @escaping () -> Void,
        @ViewBuilder result: @escaping () -> ResultActions
    ) {
        _session = ObservedObject(wrappedValue: session)
        self.title = title
        self.blurb = blurb
        self.onBack = onBack
        self.result = result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if session.ready {
                if session.engine.isComplete {
                    resultCard
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            PromptText(target: session.engine.target, index: session.engine.index)
                            if session.exercise.includesWeakKeyPractice {
                                Text("Extra practice for \(DisplayFormat.keyList(session.exercise.focusKeys)).")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.leaf)
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    ProgressView(value: Double(session.engine.index), total: Double(max(session.engine.target.count, 1)))
                        .tint(Theme.leaf)
                    FingerHintView(character: session.engine.nextCharacter, notice: notice)
                    KeyboardView(highlight: session.engine.nextCharacter) { character in
                        session.type(character)
                    }
                    .background {
                        KeyMonitor { character in
                            session.type(character)
                        }
                    }
                }
            } else {
                Spacer()
                Text("Getting the keys ready…")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.paper)
        .navigationBarBackButtonHidden(true)
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { date in
            session.advanceClock(date)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            BackButton(action: onBack)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(blurb)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.65))
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            StatPill(title: "Time", value: DisplayFormat.clock(session.elapsed))
            StatPill(title: "WPM", value: DisplayFormat.wordsPerMinute(session.stats.wordsPerMinute, elapsed: session.elapsed))
            StatPill(
                title: "Accuracy",
                value: DisplayFormat.percent(session.stats.accuracy, attempts: session.stats.correctCharacters + session.stats.mistakes)
            )
        }
    }

    private var notice: String? {
        guard let mistake = session.engine.lastMistake else { return nil }
        return GentleFeedback.message(expected: mistake.expected, typed: mistake.typed)
    }

    private var resultCard: some View {
        let stats = session.stats
        return VStack {
            Spacer()
            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Text(Encouragement.lessonComplete(stars: stats.stars))
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.ink)
                    StarRow(filled: stats.stars)
                        .scaleEffect(1.4)
                        .padding(.vertical, 6)
                    HStack(spacing: 16) {
                        StatPill(title: "WPM", value: DisplayFormat.wordsPerMinute(stats.wordsPerMinute, elapsed: stats.elapsed))
                        StatPill(title: "Accuracy", value: DisplayFormat.percent(stats.accuracy, attempts: stats.correctCharacters + stats.mistakes))
                        StatPill(title: "Time", value: DisplayFormat.clock(stats.elapsed))
                    }
                    result()
                }
            }
            .frame(maxWidth: 640)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
