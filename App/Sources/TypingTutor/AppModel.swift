import Foundation
import SwiftUI
import TypingTutorCore

@MainActor
final class AppModel: ObservableObject {
    @Published var progress: TypingProgress
    @Published var saveWarning: String?
    @Published private(set) var coach: AdaptiveCoach

    private let store: ProgressStore

    init(store: ProgressStore? = nil) {
        let resolved = store ?? ProgressStore(directory: ProgressStore.applicationSupportDirectory())
        self.store = resolved
        let loaded = resolved.load()
        progress = loaded
        coach = AdaptiveCoach(stats: loaded.keyStats)
        saveWarning = nil
    }

    func setPlayerName(_ raw: String) {
        progress.playerName = PlayerName.cleaned(raw)
        persist()
    }

    func resetProgress() {
        progress = .blank
        coach = AdaptiveCoach()
        persist()
    }

    func makeExercise(for lesson: Lesson) -> Exercise {
        let weak = coach.weakKeys(among: Set(lesson.allowedKeys))
        return ExerciseGenerator.make(lesson: lesson, weakKeys: weak, seed: freshSeed(lesson.id))
    }

    func noteOpened(lessonID: String) {
        let before = progress.furthestLessonID
        ProgressRules.noteOpened(&progress, lessonID: lessonID)
        if progress.furthestLessonID != before {
            persist()
        }
    }

    func recordLesson(lessonID: String, stats: SessionStats, coach: AdaptiveCoach, weakKeyPractice: Bool) {
        self.coach = coach
        ProgressRules.recordLesson(
            &progress,
            lessonID: lessonID,
            stats: stats,
            at: Date(),
            keyStats: coach.stats,
            weakKeyPractice: weakKeyPractice
        )
        persist()
    }

    func keepPractice(seconds: TimeInterval, coach: AdaptiveCoach) {
        self.coach = coach
        ProgressRules.addPracticeTime(&progress, seconds: seconds, keyStats: coach.stats)
        persist()
    }

    func noteKey(expected: Character, correct: Bool) {
        coach.record(expected: expected, wasCorrect: correct)
        progress.keyStats = coach.stats
    }

    func recordFalling(score: Int) {
        progress.fallingGamesPlayed += 1
        if score > progress.bestFallingScore {
            progress.bestFallingScore = score
        }
        progress.keyStats = coach.stats
        persist()
    }

    func recordRace(won: Bool) {
        progress.racesFinished += 1
        if won {
            progress.racesWon += 1
        }
        progress.keyStats = coach.stats
        persist()
    }

    func flushCoach() {
        progress.keyStats = coach.stats
        persist()
    }

    private func freshSeed(_ label: String) -> UInt64 {
        var hasher = Hasher()
        hasher.combine(Date().timeIntervalSince1970)
        hasher.combine(label)
        let mixed = hasher.finalize()
        let seed = UInt64(bitPattern: Int64(mixed))
        return seed == 0 ? 1 : seed
    }

    private func persist() {
        do {
            try store.save(progress)
            saveWarning = nil
        } catch {
            saveWarning = "Progress could not be saved on this Mac."
        }
    }
}
