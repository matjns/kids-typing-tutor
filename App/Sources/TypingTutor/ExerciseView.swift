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
            onBack: pop,
            previousTitle: LessonCatalog.previous(before: lesson.id)?.title,
            onPrevious: previousAction,
            onLessons: openLessonMap
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
                if let previous = LessonCatalog.previous(before: lesson.id) {
                    BigButton(title: "Back to: \(previous.title)", fill: Theme.sky) {
                        open(previous)
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
            model.noteOpened(lessonID: lesson.id)
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

    private var previousAction: (() -> Void)? {
        guard let previous = LessonCatalog.previous(before: lesson.id) else { return nil }
        return { open(previous) }
    }

    private func goToNext(_ next: Lesson) {
        open(next)
    }

    /// Swap this lesson for another one, keeping the screens underneath.
    private func open(_ other: Lesson) {
        guard !path.isEmpty else {
            path = [.exercise(other.id)]
            return
        }
        path.removeLast()
        path.append(.exercise(other.id))
    }

    /// Jump to the lesson path, where every open lesson can be tapped.
    private func openLessonMap() {
        if let index = path.lastIndex(of: .path) {
            path = Array(path.prefix(through: index))
        } else {
            path = [.path]
        }
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
