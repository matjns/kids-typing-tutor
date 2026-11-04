import XCTest
@testable import TypingTutorCore

final class LessonReplayTests: XCTestCase {
    private let great = SessionStats(correctCharacters: 20, mistakes: 0, elapsed: 30, completed: true)
    private let rough = SessionStats(correctCharacters: 5, mistakes: 40, elapsed: 30, completed: true)
    private let quit = SessionStats(correctCharacters: 3, mistakes: 1, elapsed: 10, completed: false)

    private func record(_ progress: inout TypingProgress, _ id: String, _ stats: SessionStats) {
        ProgressRules.recordLesson(&progress, lessonID: id, stats: stats, at: Date(timeIntervalSince1970: 1), keyStats: [:], weakKeyPractice: false)
    }

    func testPreviousLessonLookup() {
        let all = LessonCatalog.all
        XCTAssertNil(LessonCatalog.previous(before: all[0].id))
        XCTAssertEqual(LessonCatalog.previous(before: all[1].id)?.id, all[0].id)
        XCTAssertEqual(LessonCatalog.previous(before: all[all.count - 1].id)?.id, all[all.count - 2].id)
        XCTAssertNil(LessonCatalog.previous(before: "not-a-lesson"))
    }

    func testSkippedLessonStaysOpenAndLaterLessonStaysOpen() {
        let all = LessonCatalog.all
        var progress = TypingProgress.blank
        record(&progress, all[0].id, great)
        // Lesson 2 is played with no stars, then the player skips ahead to lesson 3.
        record(&progress, all[1].id, quit)
        XCTAssertEqual(progress.bestStars[all[1].id] ?? 0, 0)
        ProgressRules.noteOpened(&progress, lessonID: all[2].id)
        record(&progress, all[2].id, great)

        XCTAssertTrue(ProgressRules.isUnlocked(lesson: all[1], progress: progress), "skipped lesson must stay open")
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: all[2], progress: progress), "lesson reached by skipping stays open")
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: all[3], progress: progress), "stars on lesson 3 open lesson 4")
        XCTAssertFalse(ProgressRules.isUnlocked(lesson: all[4], progress: progress))
        XCTAssertEqual(ProgressRules.unlockedLessons(progress: progress).map(\.id), all.prefix(4).map(\.id))
        XCTAssertEqual(ProgressRules.nextLesson(in: progress).id, all[1].id, "Up next points back at the skipped lesson")
    }

    func testOpeningWithoutStarsKeepsAccess() {
        let all = LessonCatalog.all
        var progress = TypingProgress.blank
        record(&progress, all[0].id, great)
        ProgressRules.noteOpened(&progress, lessonID: all[1].id)
        ProgressRules.noteOpened(&progress, lessonID: all[2].id)
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: all[2], progress: progress))
        XCTAssertFalse(ProgressRules.isUnlocked(lesson: all[3], progress: progress))
    }

    func testReplayingEarlierLessonKeepsFurthestProgressAndStars() {
        let all = LessonCatalog.all
        var progress = TypingProgress.blank
        for lesson in all.prefix(5) {
            ProgressRules.noteOpened(&progress, lessonID: lesson.id)
            record(&progress, lesson.id, great)
        }
        let before = ProgressRules.furthestUnlockedIndex(progress: progress)
        XCTAssertEqual(before, 5)

        ProgressRules.noteOpened(&progress, lessonID: all[0].id)
        record(&progress, all[0].id, rough)
        ProgressRules.noteOpened(&progress, lessonID: all[1].id)

        XCTAssertEqual(ProgressRules.furthestUnlockedIndex(progress: progress), before)
        XCTAssertEqual(progress.furthestLessonID, all[4].id)
        XCTAssertEqual(progress.bestStars[all[0].id], 3, "best stars survive a rough replay")
        for lesson in all.prefix(6) {
            XCTAssertTrue(ProgressRules.isUnlocked(lesson: lesson, progress: progress))
        }
    }

    func testUnknownLessonIsIgnored() {
        var progress = TypingProgress.blank
        ProgressRules.noteOpened(&progress, lessonID: "not-a-lesson")
        XCTAssertNil(progress.furthestLessonID)
        XCTAssertEqual(ProgressRules.furthestUnlockedIndex(progress: progress), 0)
    }

    func testLastLessonStarsDoNotOverflow() {
        var progress = TypingProgress.blank
        for lesson in LessonCatalog.all { progress.bestStars[lesson.id] = 1 }
        XCTAssertEqual(ProgressRules.furthestUnlockedIndex(progress: progress), LessonCatalog.all.count - 1)
    }

    func testOldProgressFileWithoutFurthestLessonStillLoads() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("typing-tutor-replay-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let store = ProgressStore(directory: directory)
        let legacy = """
        {"bestFallingScore":0,"bestStars":{"home-fj":2},"fallingGamesPlayed":0,"history":[],"keyStats":{},
         "playerName":"","racesFinished":0,"racesWon":0,"totalPracticeSeconds":0,"weakKeySessions":0}
        """
        try legacy.data(using: .utf8)!.write(to: store.fileURL)
        let loaded = store.load()
        XCTAssertEqual(loaded.bestStars["home-fj"], 2)
        XCTAssertNil(loaded.furthestLessonID)
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: LessonCatalog.all[1], progress: loaded))

        var updated = loaded
        ProgressRules.noteOpened(&updated, lessonID: LessonCatalog.all[3].id)
        try store.save(updated)
        XCTAssertEqual(store.load().furthestLessonID, LessonCatalog.all[3].id)
    }
}
