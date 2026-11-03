import Foundation
import SwiftUI
import TypingTutorCore

@MainActor
final class ExerciseSession: ObservableObject {
    @Published private(set) var engine: TypingEngine
    @Published private(set) var now: Date
    @Published private(set) var ready: Bool
    private(set) var exercise: Exercise
    private(set) var coach: AdaptiveCoach
    private var savedResult = false

    init() {
        engine = TypingEngine(target: "fj")
        now = Date()
        ready = false
        exercise = Exercise(
            lessonID: "",
            title: "",
            prompt: "fj",
            suggestedSeconds: 60,
            focusKeys: [],
            includesWeakKeyPractice: false
        )
        coach = AdaptiveCoach()
    }

    var stats: SessionStats {
        engine.stats(at: now)
    }

    var elapsed: TimeInterval {
        stats.elapsed
    }

    func start(exercise: Exercise, coach: AdaptiveCoach) {
        guard !ready else { return }
        self.exercise = exercise
        self.coach = coach
        engine = TypingEngine(target: exercise.prompt)
        now = Date()
        savedResult = false
        ready = true
    }

    func restart(exercise: Exercise) {
        self.exercise = exercise
        engine = TypingEngine(target: exercise.prompt)
        now = Date()
        savedResult = false
        ready = true
    }

    func type(_ character: Character) {
        guard ready, !engine.isComplete else { return }
        guard let expected = engine.nextCharacter else { return }
        var updated = engine
        let outcome = updated.type(character, at: Date())
        engine = updated
        switch outcome {
        case .correct, .completed:
            coach.record(expected: expected, wasCorrect: true)
        case .incorrect:
            coach.record(expected: expected, wasCorrect: false)
        case .ignored:
            break
        }
        now = Date()
    }

    func advanceClock(_ date: Date) {
        guard ready, !engine.isComplete else { return }
        now = date
    }

    func claimResult() -> Bool {
        guard engine.isComplete, !savedResult else { return false }
        savedResult = true
        return true
    }

    var didSaveResult: Bool {
        savedResult
    }
}
