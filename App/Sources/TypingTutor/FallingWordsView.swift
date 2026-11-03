import Combine
import SwiftUI
import TypingTutorCore

@MainActor
final class FallingController: ObservableObject {
    @Published private(set) var game: FallingWordsGame?

    func begin(allowed: Set<Character>) {
        guard game == nil else { return }
        let seed = UInt64(Date().timeIntervalSince1970)
        game = FallingWordsGame(allowed: allowed, duration: 75, seed: seed == 0 ? 1 : seed)
    }

    func tick(delta: TimeInterval) {
        guard var current = game, !current.isOver else { return }
        current.tick(delta: delta)
        game = current
    }

    func type(_ character: Character) -> (expected: Character?, outcome: KeystrokeOutcome) {
        guard var current = game else { return (nil, .ignored) }
        let expected = current.activeWord?.nextCharacter
        let outcome = current.type(character)
        game = current
        return (expected, outcome)
    }

    func restart(allowed: Set<Character>) {
        let seed = UInt64(Date().timeIntervalSince1970)
        game = FallingWordsGame(allowed: allowed, duration: 75, seed: seed == 0 ? 2 : seed)
    }
}

struct FallingWordsView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]
    @StateObject private var controller = FallingController()
    @State private var lastTick = Date()
    @State private var didRecord = false

    var body: some View {
        VStack(spacing: 12) {
            header
            if let game = controller.game {
                playfield(game)
                if game.isOver {
                    result(game)
                } else if let active = game.activeWord {
                    typingLine(active)
                    KeyboardView(highlight: active.nextCharacter) { character in
                        type(character)
                    }
                }
            } else {
                Spacer()
                Text("Words are lining up…")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(skyBackground)
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
                Text("Falling words")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("Type the lowest word. You have three balloons.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.68))
            }
            Spacer()
            if let game = controller.game {
                StatPill(title: "Score", value: "\(game.score)")
                balloonRow(remaining: game.balloons)
            }
        }
    }

    private func playfield(_ game: FallingWordsGame) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ForEach(game.words) { word in
                    let active = game.activeWord?.id == Optional(word.id)
                    wordChip(word, active: active)
                        .position(
                            x: laneX(id: word.id, width: proxy.size.width),
                            y: 28 + word.y * max(40, proxy.size.height - 56)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func wordChip(_ word: FallingWord, active: Bool) -> some View {
        let typed = String(word.text.prefix(word.typed))
        let rest = String(word.text.dropFirst(word.typed))
        return (Text(typed).foregroundColor(active ? Color.white.opacity(0.85) : Theme.leaf)
            + Text(rest).foregroundColor(active ? Color.white : Theme.ink))
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(active ? Theme.coral : Color.white, in: Capsule())
    }

    private func typingLine(_ word: FallingWord) -> some View {
        FingerHintView(character: word.nextCharacter, notice: nil)
    }

    private func result(_ game: FallingWordsGame) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(Encouragement.fallingOver(score: game.score, balloonsLeft: game.balloons))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                HStack(spacing: 12) {
                    BigButton(title: "Play again", fill: Theme.leaf) {
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

    private func balloonRow(remaining: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < remaining ? Theme.coral : Theme.mist)
                    .frame(width: 18, height: 18)
            }
        }
        .accessibilityLabel("\(remaining) balloons left")
        .padding(.horizontal, 8)
    }

    private func laneX(id: Int, width: CGFloat) -> CGFloat {
        let slot = CGFloat(id % 5)
        return width * (0.14 + slot * 0.18)
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
        guard let game = controller.game, game.isOver, !didRecord else { return }
        didRecord = true
        model.recordFalling(score: game.score)
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    private var skyBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.80, green: 0.91, blue: 0.98), Theme.paper],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
