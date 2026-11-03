import SwiftUI
import TypingTutorCore

struct ExerciseView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]
    let lesson: Lesson
    @StateObject private var session = ExerciseSession()

    var body: some View {
        PracticeScreen(
            session: session,
            title: lesson.title,
            blurb: lesson.blurb,
            onBack: pop
        ) {
            VStack(spacing: 10) {
                if let next = LessonCatalog.next(after: lesson.id) {
                    BigButton(title: "Next: \(next.title)") {
                        goToNext(next)
                    }
                } else {
                    BigButton(title: "All lessons done") {
                        path.removeAll()
                    }
                }
                BigButton(title: "Practice again", fill: Theme.leaf) {
                    session.restart(exercise: model.makeExercise(for: lesson))
                }
                BigButton(title: "Home", fill: Theme.sky) {
                    path.removeAll()
                }
            }
        }
        .onAppear {
            session.start(exercise: model.makeExercise(for: lesson), coach: model.coach)
        }
        .onChange(of: session.engine.isComplete) { _, finished in
            guard finished else { return }
            commit()
        }
        .onDisappear {
            guard session.ready, !session.didSaveResult else { return }
            model.keepPractice(seconds: session.elapsed, coach: session.coach)
        }
    }

    private func commit() {
        guard session.claimResult() else { return }
        model.recordLesson(
            lessonID: lesson.id,
            stats: session.stats,
            coach: session.coach,
            weakKeyPractice: session.exercise.includesWeakKeyPractice
        )
    }

    private func goToNext(_ next: Lesson) {
        guard !path.isEmpty else {
            path = [.exercise(next.id)]
            return
        }
        path.removeLast()
        path.append(.exercise(next.id))
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
