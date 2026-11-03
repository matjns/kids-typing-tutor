import Foundation

public struct AttemptRecord: Codable, Equatable, Sendable {
    public var lessonID: String
    public var stars: Int
    public var accuracy: Double
    public var wordsPerMinute: Double
    public var practicedAt: Date

    public init(lessonID: String, stars: Int, accuracy: Double, wordsPerMinute: Double, practicedAt: Date) {
        self.lessonID = lessonID
        self.stars = stars
        self.accuracy = accuracy
        self.wordsPerMinute = wordsPerMinute
        self.practicedAt = practicedAt
    }
}

public struct Progress: Codable, Equatable, Sendable {
    public var playerName: String
    public var bestStars: [String: Int]
    public var keyStats: [String: KeyStat]
    public var totalPracticeSeconds: Int
    public var fallingGamesPlayed: Int
    public var bestFallingScore: Int
    public var racesFinished: Int
    public var racesWon: Int
    public var weakKeySessions: Int
    public var history: [AttemptRecord]

    public init(
        playerName: String = "",
        bestStars: [String: Int] = [:],
        keyStats: [String: KeyStat] = [:],
        totalPracticeSeconds: Int = 0,
        fallingGamesPlayed: Int = 0,
        bestFallingScore: Int = 0,
        racesFinished: Int = 0,
        racesWon: Int = 0,
        weakKeySessions: Int = 0,
        history: [AttemptRecord] = []
    ) {
        self.playerName = playerName
        self.bestStars = bestStars
        self.keyStats = keyStats
        self.totalPracticeSeconds = totalPracticeSeconds
        self.fallingGamesPlayed = fallingGamesPlayed
        self.bestFallingScore = bestFallingScore
        self.racesFinished = racesFinished
        self.racesWon = racesWon
        self.weakKeySessions = weakKeySessions
        self.history = history
    }

    public static let blank = Progress()

    public var lessonsWithStars: Int {
        bestStars.values.filter { $0 > 0 }.count
    }

    public var starTotal: Int {
        bestStars.values.reduce(0, +)
    }
}

public struct Badge: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String

    public init(id: String, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }

    public static let all: [Badge] = [
        Badge(id: "first-steps", title: "First steps", detail: "Finish a lesson."),
        Badge(id: "home-row-hero", title: "Home row hero", detail: "Finish every home row lesson."),
        Badge(id: "top-row-trek", title: "Top row trek", detail: "Finish every top row lesson."),
        Badge(id: "bottom-row-buddy", title: "Bottom row buddy", detail: "Finish every bottom row lesson."),
        Badge(id: "capital-captain", title: "Capital captain", detail: "Finish the shift lessons."),
        Badge(id: "number-navigator", title: "Number navigator", detail: "Finish the number lessons."),
        Badge(id: "punctuation-pal", title: "Punctuation pal", detail: "Finish the punctuation lessons."),
        Badge(id: "sentence-star", title: "Sentence star", detail: "Finish the sentence lessons."),
        Badge(id: "all-star", title: "All star", detail: "Earn three stars on any lesson."),
        Badge(id: "perfect-run", title: "Perfect run", detail: "Finish a lesson with no misses."),
        Badge(id: "ten-lessons", title: "Ten lessons", detail: "Collect a star on ten lessons."),
        Badge(id: "comeback-keys", title: "Comeback keys", detail: "Practice the keys that were tricky."),
        Badge(id: "falling-start", title: "Word catcher", detail: "Play a round of falling words."),
        Badge(id: "race-finisher", title: "Race finisher", detail: "Finish a race against the breeze."),
        Badge(id: "ten-minute-hero", title: "Ten minute hero", detail: "Practice for ten minutes in all.")
    ]

    public static func isEarned(_ id: String, progress: Progress) -> Bool {
        switch id {
        case "first-steps":
            return progress.lessonsWithStars >= 1
        case "home-row-hero":
            return stageComplete(.homeRow, progress)
        case "top-row-trek":
            return stageComplete(.topRow, progress)
        case "bottom-row-buddy":
            return stageComplete(.bottomRow, progress)
        case "capital-captain":
            return stageComplete(.shift, progress)
        case "number-navigator":
            return stageComplete(.numbers, progress)
        case "punctuation-pal":
            return stageComplete(.punctuation, progress)
        case "sentence-star":
            return stageComplete(.sentences, progress)
        case "all-star":
            return progress.bestStars.values.contains { $0 >= 3 }
        case "perfect-run":
            return progress.history.contains { $0.accuracy >= 0.999 && $0.stars == 3 }
        case "ten-lessons":
            return progress.lessonsWithStars >= 10
        case "comeback-keys":
            return progress.weakKeySessions >= 1
        case "falling-start":
            return progress.fallingGamesPlayed >= 1
        case "race-finisher":
            return progress.racesFinished >= 1
        case "ten-minute-hero":
            return progress.totalPracticeSeconds >= 600
        default:
            return false
        }
    }

    public static func earned(from progress: Progress) -> [Badge] {
        all.filter { isEarned($0.id, progress: progress) }
    }

    private static func stageComplete(_ stage: Stage, _ progress: Progress) -> Bool {
        let lessons = LessonCatalog.lessons(in: stage)
        guard !lessons.isEmpty else { return false }
        return lessons.allSatisfy { (progress.bestStars[$0.id] ?? 0) >= 1 }
    }
}

public enum ProgressRules {
    public static func isUnlocked(lesson: Lesson, progress: Progress) -> Bool {
        guard let index = LessonCatalog.all.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        if index == 0 { return true }
        let previous = LessonCatalog.all[index - 1]
        return (progress.bestStars[previous.id] ?? 0) >= 1
    }

    public static func nextLesson(in progress: Progress) -> Lesson {
        if let unfinished = LessonCatalog.all.first(where: { lesson in
            isUnlocked(lesson: lesson, progress: progress) && (progress.bestStars[lesson.id] ?? 0) == 0
        }) {
            return unfinished
        }
        let ranked = LessonCatalog.all.sorted { lhs, rhs in
            let leftStars = progress.bestStars[lhs.id] ?? 0
            let rightStars = progress.bestStars[rhs.id] ?? 0
            if leftStars == rightStars {
                return lhs.id < rhs.id
            }
            return leftStars < rightStars
        }
        return ranked.first ?? LessonCatalog.all[0]
    }

    public static func unlockedKeys(progress: Progress) -> Set<Character> {
        var keys = Set<Character>()
        for lesson in LessonCatalog.all where (progress.bestStars[lesson.id] ?? 0) > 0 {
            keys.formUnion(lesson.allowedKeys)
        }
        if keys.isEmpty, let first = LessonCatalog.all.first {
            keys.formUnion(first.allowedKeys)
        }
        return keys
    }

    public static func recordLesson(
        _ progress: inout Progress,
        lessonID: String,
        stats: SessionStats,
        at date: Date,
        keyStats: [String: KeyStat],
        weakKeyPractice: Bool
    ) {
        let stars = stats.stars
        let previous = progress.bestStars[lessonID] ?? 0
        if stars > previous {
            progress.bestStars[lessonID] = stars
        }
        progress.keyStats = keyStats
        progress.totalPracticeSeconds += max(0, Int(stats.elapsed.rounded()))
        if weakKeyPractice {
            progress.weakKeySessions += 1
        }
        progress.history.append(
            AttemptRecord(
                lessonID: lessonID,
                stars: stars,
                accuracy: stats.accuracy,
                wordsPerMinute: stats.wordsPerMinute,
                practicedAt: date
            )
        )
        if progress.history.count > 40 {
            progress.history.removeFirst(progress.history.count - 40)
        }
    }

    public static func addPracticeTime(_ progress: inout Progress, seconds: TimeInterval, keyStats: [String: KeyStat]) {
        progress.totalPracticeSeconds += max(0, Int(seconds.rounded()))
        progress.keyStats = keyStats
    }
}

public struct ProgressStore: Sendable {
    public static let folderName = "Typing Tutor"
    public static let fileName = "progress.json"

    public let fileURL: URL

    public init(directory: URL) {
        fileURL = directory.appendingPathComponent(ProgressStore.fileName)
    }

    public static func applicationSupportDirectory(fileManager: FileManager = .default) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        return base.appendingPathComponent(ProgressStore.folderName, isDirectory: true)
    }

    public func load() -> Progress {
        guard let data = try? Data(contentsOf: fileURL) else {
            return .blank
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let progress = try? decoder.decode(Progress.self, from: data) else {
            return .blank
        }
        var cleaned = progress
        cleaned.playerName = PlayerName.cleaned(progress.playerName)
        return cleaned
    }

    public func save(_ progress: Progress) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(progress)
        try data.write(to: fileURL, options: [.atomic])
    }
}
