import XCTest
@testable import TypingTutorCore

final class ExerciseTests: XCTestCase {
    func testExercisesStayInsideAllowedKeysAndAShortLength() {
        for lesson in LessonCatalog.all {
            for seed in [UInt64(1), 2, 7, 99] {
                let exercise = ExerciseGenerator.make(lesson: lesson, weakKeys: [], seed: seed)
                XCTAssertFalse(exercise.prompt.isEmpty, lesson.id)
                XCTAssertGreaterThanOrEqual(exercise.prompt.count, 24, lesson.id)
                XCTAssertLessThan(exercise.prompt.count, 230, "\(lesson.id) \(exercise.prompt.count)")
                for character in exercise.prompt {
                    XCTAssertTrue(
                        lesson.typingCharacters.contains(character),
                        "\(lesson.id) produced \(character)"
                    )
                }
                XCTAssertFalse(exercise.includesWeakKeyPractice)
            }
        }
    }

    func testSameSeedMakesTheSamePrompt() {
        let lesson = LessonCatalog.lesson(id: "home-words")!
        let first = ExerciseGenerator.make(lesson: lesson, weakKeys: ["s"], seed: 42)
        let second = ExerciseGenerator.make(lesson: lesson, weakKeys: ["s"], seed: 42)
        XCTAssertEqual(first.prompt, second.prompt)
    }

    func testDifferentSeedsUsuallyChangeThePrompt() {
        let lesson = LessonCatalog.lesson(id: "top-words")!
        let first = ExerciseGenerator.make(lesson: lesson, weakKeys: [], seed: 1)
        let second = ExerciseGenerator.make(lesson: lesson, weakKeys: [], seed: 2)
        XCTAssertNotEqual(first.prompt, second.prompt)
    }

    func testWeakKeysAreRepeated() {
        let lesson = LessonCatalog.lesson(id: "home-words")!
        let exercise = ExerciseGenerator.make(lesson: lesson, weakKeys: ["s"], seed: 3)
        XCTAssertTrue(exercise.includesWeakKeyPractice)
        let count = exercise.prompt.filter { $0 == "s" }.count
        XCTAssertGreaterThan(count, 3)
        XCTAssertEqual(exercise.focusKeys, ["s"])
    }

    func testWeakKeysOutsideTheLessonAreIgnored() {
        let lesson = LessonCatalog.lesson(id: "home-fj")!
        let exercise = ExerciseGenerator.make(lesson: lesson, weakKeys: ["q"], seed: 1)
        XCTAssertFalse(exercise.includesWeakKeyPractice)
        XCTAssertFalse(exercise.prompt.contains("q"))
        XCTAssertTrue(exercise.prompt.allSatisfy { "fj ".contains($0) })
    }

    func testLengthLabelsMatchTheOneToThreeMinuteWindow() {
        XCTAssertEqual(ExerciseGenerator.targetLength(forSuggestedSeconds: 60), 48)
        XCTAssertEqual(ExerciseGenerator.targetLength(forSuggestedSeconds: 120), 96)
        XCTAssertEqual(ExerciseGenerator.targetLength(forSuggestedSeconds: 180), 150)
        let short = ExerciseGenerator.make(lesson: LessonCatalog.all[0], weakKeys: [], seed: 1)
        XCTAssertEqual(short.lengthLabel, "About 1 minute")
        let long = ExerciseGenerator.make(lesson: LessonCatalog.lesson(id: "sentences-long")!, weakKeys: [], seed: 1)
        XCTAssertEqual(long.lengthLabel, "About 3 minutes")
    }

    func testWeakKeyExerciseNeedsARealWeakKey() {
        let allowed = Set(LessonCatalog.lesson(id: "home-words")!.allowedKeys)
        XCTAssertNil(ExerciseGenerator.weakKeyExercise(allowed: allowed, weakKeys: [], seed: 1))
        let exercise = ExerciseGenerator.weakKeyExercise(allowed: allowed, weakKeys: ["a"], seed: 5)
        XCTAssertEqual(exercise?.lessonID, "weak-keys")
        XCTAssertTrue(exercise?.includesWeakKeyPractice ?? false)
        XCTAssertTrue(exercise?.prompt.contains("a") ?? false)
    }

    func testRacePhraseUsesOnlyUnlockedLetters() {
        let allowed = Set(LessonCatalog.lesson(id: "home-fj")!.allowedKeys)
        let phrase = ExerciseGenerator.racePhrase(allowed: allowed, seed: 9)
        XCTAssertGreaterThanOrEqual(phrase.count, 20)
        for character in phrase {
            XCTAssertTrue(allowed.union([" "]).contains(character))
        }
    }
}
