import SwiftUI
import TypingTutorCore

struct WeakKeysView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]
    @StateObject private var session = ExerciseSession()
    @State private var mode: Mode = .checking

    private enum Mode {
        case checking
        case empty
        case practice
    }

    var body: some View {
        Group {
            switch mode {
            case .checking:
                VStack {
                    Text("Looking for tricky keys…")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.paper)
            case .empty:
                emptyState
            case .practice:
                PracticeScreen(
                    session: session,
                    title: "Tricky keys",
                    blurb: "A short extra round for keys that need more practice.",
                    onBack: pop
                ) {
                    VStack(spacing: 10) {
                        BigButton(title: "Practice again", fill: Theme.leaf) {
                            begin(reset: true)
                        }
                        BigButton(title: "Home", fill: Theme.sky) {
                            path.removeAll()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if mode == .checking {
                begin(reset: false)
            }
        }
        .onChange(of: session.engine.isComplete) { _, finished in
            guard finished, mode == .practice else { return }
            guard session.claimResult() else { return }
            model.recordLesson(
                lessonID: session.exercise.lessonID,
                stats: session.stats,
                coach: session.coach,
                weakKeyPractice: true
            )
        }
        .onDisappear {
            guard mode == .practice, session.ready, !session.didSaveResult else { return }
            model.keepPractice(seconds: session.elapsed, coach: session.coach)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            BackButton(action: pop)
            Spacer()
            Text("No tricky keys yet")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text("Play a lesson first. If a key is missed a few times, it will wait here for extra practice.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.72))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 460)
            BigButton(title: "Lesson path", fill: Theme.leaf) {
                path.append(.path)
            }
            .frame(maxWidth: 320)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.paper)
    }

    private func begin(reset: Bool) {
        let allowed = ProgressRules.unlockedKeys(progress: model.progress)
        let weak = model.coach.weakKeys(among: allowed)
        guard let exercise = ExerciseGenerator.weakKeyExercise(allowed: allowed, weakKeys: weak, seed: UInt64(Date().timeIntervalSince1970)) else {
            mode = .empty
            return
        }
        if reset || !session.ready {
            if session.ready {
                session.restart(exercise: exercise)
            } else {
                session.start(exercise: exercise, coach: model.coach)
            }
        }
        mode = .practice
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
