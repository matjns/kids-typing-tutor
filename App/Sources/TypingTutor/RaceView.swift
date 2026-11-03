import Combine
import SwiftUI
import TypingTutorCore

@MainActor
final class RaceController: ObservableObject {
    @Published private(set) var race: RaceGame?

    func begin(allowed: Set<Character>) {
        guard race == nil else { return }
        race = make(allowed: allowed, salt: 1)
    }

    func restart(allowed: Set<Character>) {
        race = make(allowed: allowed, salt: Date().timeIntervalSince1970)
    }

    func tick(delta: TimeInterval) {
        guard var current = race, !current.isComplete else { return }
        current.tick(delta: delta)
        race = current
    }

    func type(_ character: Character) -> (expected: Character?, outcome: KeystrokeOutcome) {
        guard var current = race else { return (nil, .ignored) }
        let expected = current.nextCharacter
        let outcome = current.type(character)
        race = current
        return (expected, outcome)
    }

    private func make(allowed: Set<Character>, salt: Double) -> RaceGame {
        var hasher = Hasher()
        hasher.combine(salt)
        hasher.combine(allowed.count)
        let seed = UInt64(bitPattern: Int64(hasher.finalize()))
        let phrase = ExerciseGenerator.racePhrase(allowed: allowed, seed: seed == 0 ? 1 : seed)
        return RaceGame(phrase: phrase)
    }
}

struct RaceView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]
    @StateObject private var controller = RaceController()
    @State private var lastTick = Date()
    @State private var didRecord = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if let race = controller.race {
                track(race)
                if race.paceIsAhead {
                    Text(Encouragement.paceNote(paceAhead: true))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.ink.opacity(0.75))
                }
                if race.isComplete {
                    result(race)
                } else {
                    ScrollView {
                        PromptText(target: race.phrase, index: race.index)
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    FingerHintView(character: race.nextCharacter, notice: nil)
                    KeyboardView(highlight: race.nextCharacter) { character in
                        type(character)
                    }
                }
            } else {
                Spacer()
                Text("The breeze is stretching…")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.paper)
        .navigationBarBackButtonHidden(true)
        .background {
            KeyMonitor(onCharacter: type)
        }
        .onAppear {
            controller.begin(allowed: ProgressRules.unlockedKeys(progress: model.progress))
            lastTick = Date()
        }
        .onDisappear {
            model.flushCoach()
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { date in
            let delta = min(0.1, max(0, date.timeIntervalSince(lastTick)))
            lastTick = date
            controller.tick(delta: delta)
            recordIfNeeded()
        }
    }

    private var header: some View {
        HStack {
            BackButton { pop() }
            VStack(alignment: .leading, spacing: 2) {
                Text("Race")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("You are the coral dot. The breeze moves on its own.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.68))
            }
            Spacer()
        }
    }

    private func track(_ race: RaceGame) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { proxy in
                let width = max(40, proxy.size.width - 36)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.mist)
                        .frame(height: 22)
                    Capsule()
                        .fill(Theme.leaf.opacity(0.45))
                        .frame(width: max(22, width * race.playerProgress), height: 22)
                    Circle()
                        .fill(Theme.sky)
                        .frame(width: 26, height: 26)
                        .offset(x: width * race.paceProgress)
                    Circle()
                        .fill(Theme.coral)
                        .frame(width: 34, height: 34)
                        .offset(x: width * race.playerProgress)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.ink.opacity(0.7))
                        .frame(width: 4, height: 36)
                        .offset(x: width)
                }
            }
            .frame(height: 40)
            HStack {
                Text(racerName)
                    .foregroundStyle(Theme.coral)
                Spacer()
                Text("Breeze")
                    .foregroundStyle(Theme.sky)
                Spacer()
                Text("Finish")
                    .foregroundStyle(Theme.ink.opacity(0.6))
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var racerName: String {
        let cleaned = PlayerName.cleaned(model.progress.playerName)
        if cleaned.isEmpty { return "You" }
        return cleaned
    }

    private func result(_ race: RaceGame) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(Encouragement.raceFinish(won: race.playerWon))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                StatPill(
                    title: "Accuracy",
                    value: DisplayFormat.percent(race.accuracy, attempts: race.index + race.mistakes)
                )
                HStack(spacing: 12) {
                    BigButton(title: "Race again", fill: Theme.leaf) {
                        didRecord = false
                        controller.restart(allowed: ProgressRules.unlockedKeys(progress: model.progress))
                    }
                    BigButton(title: "Home", fill: Theme.sky) {
                        path.removeAll()
                    }
                }
            }
        }
    }

    private func type(_ character: Character) {
        let keyResult = controller.type(character)
        if let expected = keyResult.expected, keyResult.outcome != .ignored {
            let correct = keyResult.outcome == .correct || keyResult.outcome == .completed
            model.noteKey(expected: expected, correct: correct)
        }
        recordIfNeeded()
    }

    private func recordIfNeeded() {
        guard let race = controller.race, race.isComplete, !didRecord else { return }
        didRecord = true
        model.recordRace(won: race.playerWon)
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
