import Foundation

public enum KeystrokeOutcome: Equatable, Sendable {
    case correct
    case incorrect
    case completed
    case ignored
}

public struct Mistake: Equatable, Sendable {
    public let expected: Character
    public let typed: Character

    public init(expected: Character, typed: Character) {
        self.expected = expected
        self.typed = typed
    }
}

public struct SessionStats: Equatable, Sendable {
    public let correctCharacters: Int
    public let mistakes: Int
    public let elapsed: TimeInterval
    public let completed: Bool

    public var accuracy: Double {
        let total = correctCharacters + mistakes
        guard total > 0 else { return 1 }
        return Double(correctCharacters) / Double(total)
    }

    public var wordsPerMinute: Double {
        Scoring.wordsPerMinute(correctCharacters: correctCharacters, elapsed: elapsed)
    }

    public var stars: Int {
        Stars.rate(accuracy: accuracy, completed: completed)
    }

    public init(correctCharacters: Int, mistakes: Int, elapsed: TimeInterval, completed: Bool) {
        self.correctCharacters = correctCharacters
        self.mistakes = mistakes
        self.elapsed = elapsed
        self.completed = completed
    }
}

public enum Scoring {
    /// Standard typing words: five characters count as one word.
    public static func wordsPerMinute(correctCharacters: Int, elapsed: TimeInterval) -> Double {
        guard elapsed >= 1, correctCharacters > 0 else { return 0 }
        return (Double(correctCharacters) / 5.0) / (elapsed / 60.0)
    }
}

public enum Stars {
    /// Finishing always earns a star. Cleaner typing earns two or three.
    public static func rate(accuracy: Double, completed: Bool) -> Int {
        guard completed else { return 0 }
        if accuracy >= 0.97 { return 3 }
        if accuracy >= 0.90 { return 2 }
        return 1
    }
}

public struct TypingEngine: Equatable, Sendable {
    public let target: String
    public private(set) var index: Int
    public private(set) var correctCount: Int
    public private(set) var mistakeCount: Int
    public private(set) var startedAt: Date?
    public private(set) var finishedAt: Date?
    public private(set) var lastMistake: Mistake?

    public init(target: String) {
        self.target = target
        self.index = 0
        self.correctCount = 0
        self.mistakeCount = 0
        self.startedAt = nil
        self.finishedAt = nil
        self.lastMistake = nil
    }

    public var isComplete: Bool {
        finishedAt != nil
    }

    public var nextCharacter: Character? {
        guard index < target.count else { return nil }
        let stringIndex = target.index(target.startIndex, offsetBy: index)
        return target[stringIndex]
    }

    @discardableResult
    public mutating func type(_ character: Character, at date: Date) -> KeystrokeOutcome {
        guard finishedAt == nil else { return .ignored }
        if startedAt == nil {
            startedAt = date
        }
        guard let expected = nextCharacter else {
            finishedAt = date
            return .completed
        }
        if character == expected {
            correctCount += 1
            index += 1
            lastMistake = nil
            if index >= target.count {
                finishedAt = date
                return .completed
            }
            return .correct
        }
        mistakeCount += 1
        lastMistake = Mistake(expected: expected, typed: character)
        return .incorrect
    }

    public func stats(at date: Date) -> SessionStats {
        let end = finishedAt ?? date
        let elapsed: TimeInterval
        if let startedAt {
            elapsed = max(0, end.timeIntervalSince(startedAt))
        } else {
            elapsed = 0
        }
        return SessionStats(
            correctCharacters: correctCount,
            mistakes: mistakeCount,
            elapsed: elapsed,
            completed: finishedAt != nil
        )
    }
}
