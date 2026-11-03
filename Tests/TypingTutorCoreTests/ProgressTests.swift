import XCTest
@testable import TypingTutorCore

final class ProgressTests: XCTestCase {
    func testBlankProgressHasNoName() {
        XCTAssertEqual(Progress.blank.playerName, "")
        XCTAssertEqual(Greeting.homeTitle(name: ""), "Hi there")
        XCTAssertEqual(Greeting.homeTitle(name: "   "), "Hi there")
        XCTAssertEqual(Greeting.homeTitle(name: "ABC"), "Hi, ABC")
        XCTAssertEqual(PlayerName.cleaned("  ABC   DEF  \n"), "ABC DEF")
        XCTAssertEqual(PlayerName.cleaned(String(repeating: "Z", count: 40)).count, 16)
    }

    func testUnlocksAndBestStars() {
        var progress = Progress.blank
        let first = LessonCatalog.all[0]
        let second = LessonCatalog.all[1]
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: first, progress: progress))
        XCTAssertFalse(ProgressRules.isUnlocked(lesson: second, progress: progress))
        XCTAssertEqual(ProgressRules.nextLesson(in: progress).id, first.id)

        let great = SessionStats(correctCharacters: 20, mistakes: 0, elapsed: 30, completed: true)
        ProgressRules.recordLesson(&progress, lessonID: first.id, stats: great, at: Date(timeIntervalSince1970: 10), keyStats: [:], weakKeyPractice: false)
        XCTAssertEqual(progress.bestStars[first.id], 3)
        XCTAssertTrue(ProgressRules.isUnlocked(lesson: second, progress: progress))
        XCTAssertEqual(progress.lessonsWithStars, 1)
        XCTAssertTrue(Badge.isEarned("first-steps", progress: progress))
        XCTAssertTrue(Badge.isEarned("all-star", progress: progress))
        XCTAssertTrue(Badge.isEarned("perfect-run", progress: progress))
        XCTAssertFalse(Badge.isEarned("home-row-hero", progress: progress))

        let rough = SessionStats(correctCharacters: 20, mistakes: 10, elapsed: 40, completed: true)
        ProgressRules.recordLesson(&progress, lessonID: first.id, stats: rough, at: Date(timeIntervalSince1970: 20), keyStats: [:], weakKeyPractice: true)
        XCTAssertEqual(progress.bestStars[first.id], 3, "a later try should not take stars away")
        XCTAssertEqual(progress.weakKeySessions, 1)
        XCTAssertTrue(Badge.isEarned("comeback-keys", progress: progress))
    }

    func testStageBadgeAndTenMinuteBadge() {
        var progress = Progress.blank
        for lesson in LessonCatalog.lessons(in: .homeRow) {
            let stats = SessionStats(correctCharacters: 10, mistakes: 1, elapsed: 20, completed: true)
            ProgressRules.recordLesson(&progress, lessonID: lesson.id, stats: stats, at: Date(timeIntervalSince1970: 30), keyStats: [:], weakKeyPractice: false)
        }
        XCTAssertTrue(Badge.isEarned("home-row-hero", progress: progress))
        progress.totalPracticeSeconds = 600
        XCTAssertTrue(Badge.isEarned("ten-minute-hero", progress: progress))
        progress.fallingGamesPlayed = 1
        progress.racesFinished = 1
        XCTAssertTrue(Badge.isEarned("falling-start", progress: progress))
        XCTAssertTrue(Badge.isEarned("race-finisher", progress: progress))
    }

    func testHistoryIsCapped() {
        var progress = Progress.blank
        let stats = SessionStats(correctCharacters: 5, mistakes: 0, elapsed: 5, completed: true)
        for index in 0..<45 {
            ProgressRules.recordLesson(&progress, lessonID: "home-fj", stats: stats, at: Date(timeIntervalSince1970: Double(index)), keyStats: [:], weakKeyPractice: false)
        }
        XCTAssertEqual(progress.history.count, 40)
    }

    func testStoreRoundTripAndCorruptFile() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("typing-tutor-tests-\(UUID().uuidString)", isDirectory: true)
        let store = ProgressStore(directory: directory)
        XCTAssertEqual(store.load().playerName, "")
        var progress = Progress.blank
        progress.playerName = "ABC"
        progress.bestStars["home-fj"] = 2
        progress.keyStats["f"] = KeyStat(seen: 4, missed: 1)
        progress.history = [
            AttemptRecord(lessonID: "home-fj", stars: 2, accuracy: 0.95, wordsPerMinute: 12, practicedAt: Date(timeIntervalSince1970: 1_700_000_000))
        ]
        try store.save(progress)
        let loaded = store.load()
        XCTAssertEqual(loaded.playerName, "ABC")
        XCTAssertEqual(loaded.bestStars["home-fj"], 2)
        XCTAssertEqual(loaded.keyStats["f"], KeyStat(seen: 4, missed: 1))
        XCTAssertEqual(loaded.history.count, 1)
        XCTAssertEqual(loaded.history[0].stars, 2)

        try "not json".data(using: .utf8)?.write(to: store.fileURL)
        XCTAssertEqual(store.load().playerName, "")

        let messy = Progress(playerName: "  ABC \n")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(messy)
        try data.write(to: store.fileURL)
        XCTAssertEqual(store.load().playerName, "ABC")

        let support = ProgressStore.applicationSupportDirectory()
        XCTAssertTrue(support.path.contains(ProgressStore.folderName))
        XCTAssertEqual(ProgressStore.folderName, "Typing Tutor")
    }

    func testUnlockedKeysGrowWithStars() {
        var progress = Progress.blank
        XCTAssertEqual(ProgressRules.unlockedKeys(progress: progress), Set(LessonCatalog.all[0].allowedKeys))
        progress.bestStars[LessonCatalog.all[0].id] = 1
        progress.bestStars[LessonCatalog.all[1].id] = 1
        let keys = ProgressRules.unlockedKeys(progress: progress)
        XCTAssertTrue(keys.isSuperset(of: Set(LessonCatalog.all[1].allowedKeys)))
    }
}
