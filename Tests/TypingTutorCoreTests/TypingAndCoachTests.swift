import XCTest
@testable import TypingTutorCore

final class TypingAndCoachTests: XCTestCase {
    func testCorrectTypingAdvancesAndWrongTypingDoesNot() {
        var engine = TypingEngine(target: "ab")
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        XCTAssertEqual(engine.type("x", at: start), .incorrect)
        XCTAssertEqual(engine.index, 0)
        XCTAssertEqual(engine.lastMistake?.expected, "a")
        XCTAssertEqual(engine.type("a", at: start), .correct)
        XCTAssertEqual(engine.type("b", at: start.addingTimeInterval(2)), .completed)
        XCTAssertTrue(engine.isComplete)
        XCTAssertEqual(engine.type("b", at: start), .ignored)
        let stats = engine.stats(at: start.addingTimeInterval(2))
        XCTAssertEqual(stats.correctCharacters, 2)
        XCTAssertEqual(stats.mistakes, 1)
        XCTAssertEqual(stats.accuracy, 2.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(stats.stars, 1)
    }

    func testWordsPerMinuteAndStarBands() {
        var engine = TypingEngine(target: String(repeating: "a", count: 100))
        let start = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(engine.type("a", at: start), .correct)
        for _ in 1..<99 {
            XCTAssertEqual(engine.type("a", at: start.addingTimeInterval(60)), .correct)
        }
        XCTAssertEqual(engine.type("a", at: start.addingTimeInterval(60)), .completed)
        let stats = engine.stats(at: start.addingTimeInterval(60))
        XCTAssertEqual(stats.wordsPerMinute, 20, accuracy: 0.001)
        XCTAssertEqual(stats.stars, 3)

        XCTAssertEqual(Stars.rate(accuracy: 0.97, completed: true), 3)
        XCTAssertEqual(Stars.rate(accuracy: 0.95, completed: true), 2)
        XCTAssertEqual(Stars.rate(accuracy: 0.90, completed: true), 2)
        XCTAssertEqual(Stars.rate(accuracy: 0.89, completed: true), 1)
        XCTAssertEqual(Stars.rate(accuracy: 1, completed: false), 0)
        XCTAssertEqual(Scoring.wordsPerMinute(correctCharacters: 10, elapsed: 0.2), 0)
    }

    func testCoachFindsAndForgetsWeakKeys() {
        var coach = AdaptiveCoach()
        XCTAssertTrue(coach.weakKeys(among: ["s", "a"]).isEmpty)
        for _ in 0..<3 {
            coach.record(expected: "s", wasCorrect: false)
        }
        XCTAssertTrue(coach.weakKeys(among: ["s"]).isEmpty, "needs four tries before a key is called tricky")
        coach.record(expected: "s", wasCorrect: false)
        XCTAssertEqual(coach.weakKeys(among: ["s", "a"]), ["s"])
        for _ in 0..<40 {
            coach.record(expected: "s", wasCorrect: true)
        }
        XCTAssertFalse(coach.weakKeys(among: ["s"]).contains("s"))
    }

    func testCoachOrdersTheHardestKeyFirst() {
        var coach = AdaptiveCoach()
        for _ in 0..<5 { coach.record(expected: "f", wasCorrect: false) }
        for _ in 0..<4 { coach.record(expected: "j", wasCorrect: true) }
        coach.record(expected: "j", wasCorrect: false)
        let weak = coach.weakKeys(among: ["f", "j"])
        XCTAssertEqual(weak.first, "f")
    }

    func testFeedbackNamesTheFingerAndStaysKind() {
        let caps = GentleFeedback.message(expected: "f", typed: "F")
        XCTAssertTrue(caps.contains("Caps lock"))
        XCTAssertTrue(caps.contains("left index finger"))
        let shift = GentleFeedback.message(expected: "F", typed: "f")
        XCTAssertTrue(shift.contains("shift"))
        XCTAssertTrue(shift.contains("left index finger"))
        let miss = GentleFeedback.message(expected: "j", typed: "k")
        XCTAssertTrue(miss.contains("right index finger"))
        XCTAssertTrue(miss.contains("J"))
        let messages = [caps, shift, miss, Encouragement.lessonComplete(stars: 1), Encouragement.raceFinish(won: false), Encouragement.fallingOver(score: 3, balloonsLeft: 0), Encouragement.paceNote(paceAhead: true)]
        for message in messages {
            let lowered = message.lowercased()
            for banned in GentleFeedback.bannedSnippets {
                XCTAssertFalse(lowered.contains(banned), message)
            }
        }
    }

    func testCoachLineTellsWhichShift() {
        XCTAssertTrue(KeyboardMap.coachLine(for: "f").contains("left index finger"))
        XCTAssertTrue(KeyboardMap.coachLine(for: "A").contains("right shift"))
        XCTAssertTrue(KeyboardMap.coachLine(for: "J").contains("left shift"))
        XCTAssertNil(KeyboardMap.oppositeShift(for: "f"))
        XCTAssertEqual(KeyboardMap.oppositeShift(for: "F"), .right)
        XCTAssertEqual(KeyboardMap.oppositeShift(for: "J"), .left)
        XCTAssertEqual(KeyboardMap.oppositeShift(for: "?"), .left)
        XCTAssertEqual(KeyboardMap.oppositeShift(for: "!"), .right)
        XCTAssertEqual(KeyboardMap.finger(for: " "), .thumb)
        XCTAssertEqual(KeyboardMap.baseKey(for: "\""), "'")
        XCTAssertEqual(KeyboardMap.baseKey(for: "?"), "/")
    }

    func testEveryTaughtKeyIsOnTheKeyboard() {
        let onKeyboard = Set(KeyboardMap.rows.flatMap { $0 }.compactMap(\.character))
        for lesson in LessonCatalog.all {
            for character in lesson.allowedKeys {
                let base = KeyboardMap.baseKey(for: character)
                XCTAssertTrue(onKeyboard.contains(base), "\(character) maps to \(base)")
                _ = KeyboardMap.finger(for: character)
            }
        }
        XCTAssertTrue(onKeyboard.contains(" "))
        let ids = KeyboardMap.rows.flatMap { $0 }.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}
