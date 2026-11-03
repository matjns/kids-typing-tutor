import XCTest
@testable import TypingTutorCore

final class CatalogTests: XCTestCase {
    func testPathStartsOnHomeRowAndAddsKeysInOrder() {
        let stages = LessonCatalog.all.map(\.stage)
        XCTAssertEqual(stages.first, .homeRow)
        var lastOrder = 0
        for stage in stages {
            XCTAssertGreaterThanOrEqual(stage.order, lastOrder)
            lastOrder = stage.order
        }
        let required: [Stage] = [.homeRow, .topRow, .bottomRow, .shift, .numbers, .punctuation]
        for stage in required {
            XCTAssertTrue(stages.contains(stage), stage.title)
        }
        XCTAssertEqual(LessonCatalog.all.first?.id, "home-fj")
        XCTAssertEqual(LessonCatalog.all.first?.newKeys, ["f", "j"])
    }

    func testKeysAreIntroducedGradually() {
        var unlocked = Set<Character>()
        for lesson in LessonCatalog.all {
            let introduced = Set(lesson.newKeys)
            XCTAssertTrue(introduced.isSubset(of: Set(lesson.allowedKeys)), lesson.id)
            if !introduced.isEmpty {
                XCTAssertTrue(introduced.isDisjoint(with: unlocked), "\(lesson.id) repeats \(introduced.intersection(unlocked))")
            }
            for character in lesson.allowedKeys {
                XCTAssertNotEqual(character, " ")
            }
            unlocked.formUnion(lesson.allowedKeys)
        }
        XCTAssertTrue(unlocked.contains("f"))
        XCTAssertTrue(unlocked.contains("?"))
        XCTAssertTrue(unlocked.contains("1"))
        XCTAssertTrue(unlocked.contains("A"))
    }

    func testSamplesOnlyUseAllowedKeys() {
        for lesson in LessonCatalog.all {
            for sample in lesson.samples {
                XCTAssertFalse(sample.isEmpty, lesson.id)
                for character in sample {
                    XCTAssertTrue(
                        lesson.typingCharacters.contains(character),
                        "\(lesson.id) sample contains \(character) in \"\(sample)\""
                    )
                }
                let lowered = sample.lowercased()
                XCTAssertFalse(lowered.contains("http"))
                XCTAssertFalse(lowered.contains("www."))
                XCTAssertFalse(sample.contains("@"))
            }
        }
    }

    func testWordLessonsHaveEnoughWords() {
        for lesson in LessonCatalog.all where lesson.mode == .words {
            let allowed = Set(lesson.allowedKeys)
            let matches = WordBank.words.filter { word in
                word.count >= 2 && word.allSatisfy { allowed.contains($0) }
            }
            XCTAssertGreaterThanOrEqual(matches.count, 8, lesson.id)
        }
    }

    func testWordBankIsPlainLowercaseWords() {
        XCTAssertEqual(WordBank.words.count, Set(WordBank.words).count)
        for word in WordBank.words {
            XCTAssertGreaterThanOrEqual(word.count, 2)
            XCTAssertTrue(word.allSatisfy { $0.isLetter && $0.isLowercase }, word)
        }
    }

    func testLessonCopyIsOriginalAndOffline() {
        let blob = LessonCatalog.all.map { "\($0.title) \($0.blurb) \($0.samples.joined(separator: " "))" }.joined(separator: "\n")
        XCTAssertFalse(blob.lowercased().contains("http"))
        XCTAssertFalse(blob.contains("@"))
        XCTAssertTrue(blob.contains("F and J"))
    }
}
