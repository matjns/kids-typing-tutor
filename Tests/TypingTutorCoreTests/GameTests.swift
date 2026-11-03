import XCTest
@testable import TypingTutorCore

final class GameTests: XCTestCase {
    func testFallingWordScoresWhenTypedAndMissesAtTheBottom() {
        var game = FallingWordsGame(allowed: Set("fj"), duration: 75, seed: 4)
        let first = game.activeWord
        XCTAssertNotNil(first)
        for character in first?.text ?? "" {
            XCTAssertTrue(Set("fj").contains(character))
        }
        let wrong: Character = (first?.nextCharacter == "f") ? "j" : "f"
        XCTAssertEqual(game.type(wrong), .incorrect)
        XCTAssertEqual(game.activeWord?.typed, 0)
        for character in first?.text ?? "" {
            _ = game.type(character)
        }
        XCTAssertEqual(game.score, first?.text.count)
        XCTAssertFalse(game.words.contains { $0.id == first?.id })

        var falling = FallingWordsGame(allowed: Set("asdf"), duration: 75, seed: 8)
        falling.tick(delta: 40)
        XCTAssertGreaterThan(falling.misses, 0)
        XCTAssertLessThan(falling.balloons, 3)
    }

    func testFallingGameEndsWhenTimeRunsOut() {
        var game = FallingWordsGame(allowed: Set("asdfghjkl"), duration: 10, seed: 2)
        game.tick(delta: 10)
        XCTAssertTrue(game.isOver)
        XCTAssertEqual(game.type("a"), .ignored)
    }

    func testFallingWordsStayInsideAllowedLetters() {
        var game = FallingWordsGame(allowed: Set("asdfl"), duration: 30, seed: 11)
        for _ in 0..<6 {
            for word in game.words {
                for character in word.text {
                    XCTAssertTrue(Set("asdfl").contains(character), word.text)
                }
            }
            game.tick(delta: 3.2)
        }
    }

    func testRaceAdvancesOnlyOnTheRightLetter() {
        var race = RaceGame(phrase: "ab c", paceCharactersPerSecond: 1)
        XCTAssertEqual(race.type("z"), .incorrect)
        XCTAssertEqual(race.index, 0)
        XCTAssertEqual(race.type("a"), .correct)
        XCTAssertEqual(race.type("b"), .correct)
        XCTAssertEqual(race.type(" "), .correct)
        XCTAssertEqual(race.type("c"), .completed)
        XCTAssertTrue(race.playerWon)
        XCTAssertEqual(race.accuracy, 4.0 / 5.0, accuracy: 0.0001)
    }

    func testRaceCanFinishAfterTheBreeze() {
        var race = RaceGame(phrase: "abcd", paceCharactersPerSecond: 1)
        race.tick(delta: 20)
        XCTAssertTrue(race.paceIsAhead)
        XCTAssertFalse(race.isComplete)
        for character in "abcd" {
            _ = race.type(character)
        }
        XCTAssertTrue(race.isComplete)
        XCTAssertFalse(race.playerWon)
        XCTAssertFalse(Encouragement.raceFinish(won: false).lowercased().contains("fail"))
    }

    func testSameFallingSeedStartsTheSameWay() {
        let first = FallingWordsGame(allowed: Set("thedog"), duration: 75, seed: 15).activeWord?.text
        let second = FallingWordsGame(allowed: Set("thedog"), duration: 75, seed: 15).activeWord?.text
        XCTAssertEqual(first, second)
        XCTAssertNotNil(first)
    }
}
