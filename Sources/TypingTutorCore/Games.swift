import Foundation

public struct FallingWord: Equatable, Identifiable, Sendable {
    public let id: Int
    public let text: String
    public var y: Double
    public var typed: Int

    public init(id: Int, text: String, y: Double, typed: Int) {
        self.id = id
        self.text = text
        self.y = y
        self.typed = typed
    }

    public var isComplete: Bool {
        typed >= text.count
    }

    public var nextCharacter: Character? {
        guard typed < text.count else { return nil }
        let stringIndex = text.index(text.startIndex, offsetBy: typed)
        return text[stringIndex]
    }
}

public struct FallingWordsGame: Sendable {
    public var words: [FallingWord]
    public var score: Int
    public var misses: Int
    public var balloons: Int
    public var elapsed: TimeInterval
    public let duration: TimeInterval
    public var isOver: Bool
    public var clearedWord: String?
    public let allowed: Set<Character>
    public private(set) var nextID: Int
    private var spawnTimer: TimeInterval
    private var rngState: UInt64

    public init(allowed: Set<Character>, duration: TimeInterval = 75, seed: UInt64) {
        self.allowed = allowed
        self.duration = duration
        self.words = []
        self.score = 0
        self.misses = 0
        self.balloons = 3
        self.elapsed = 0
        self.isOver = false
        self.clearedWord = nil
        self.nextID = 1
        self.spawnTimer = 0
        self.rngState = seed == 0 ? 1 : seed
        spawn()
    }

    public var activeWord: FallingWord? {
        words.max { $0.y < $1.y }
    }

    public mutating func tick(delta: TimeInterval) {
        guard !isOver else { return }
        let step = max(delta, 0)
        elapsed += step
        clearedWord = nil
        let speed = 0.05 + min(0.03, elapsed / 800)
        for index in words.indices {
            words[index].y += speed * step
        }
        var fallen = 0
        words.removeAll { word in
            if word.y >= 1 {
                fallen += 1
                return true
            }
            return false
        }
        if fallen > 0 {
            misses += fallen
            balloons = max(0, balloons - fallen)
        }
        if balloons == 0 || elapsed >= duration {
            isOver = true
            return
        }
        spawnTimer += step
        if words.count < 3 && spawnTimer >= 3.2 {
            spawn()
            spawnTimer = 0
        }
        if words.isEmpty {
            spawn()
        }
    }

    @discardableResult
    public mutating func type(_ character: Character) -> KeystrokeOutcome {
        guard !isOver, let active = activeWord, let index = words.firstIndex(where: { $0.id == active.id }) else {
            return .ignored
        }
        guard let expected = words[index].nextCharacter else { return .ignored }
        if character == expected {
            words[index].typed += 1
            if words[index].isComplete {
                score += words[index].text.count
                clearedWord = words[index].text
                words.remove(at: index)
                if words.isEmpty {
                    spawn()
                }
                return .completed
            }
            return .correct
        }
        misses += 1
        return .incorrect
    }

    private mutating func spawn() {
        var rng = SplitMix64(state: rngState)
        let text = WordBank.randomWord(allowed: allowed, minimumLength: 2, maximumLength: 6, rng: &rng)
            ?? Self.fallbackToken(allowed: allowed, rng: &rng)
        rngState = rng.state
        words.append(FallingWord(id: nextID, text: text, y: 0, typed: 0))
        nextID += 1
    }

    private static func fallbackToken(allowed: Set<Character>, rng: inout SplitMix64) -> String {
        let letters = allowed.filter { $0.isLetter }.sorted()
        if letters.isEmpty {
            return "fj"
        }
        var tokens: [String] = []
        for character in letters {
            tokens.append(String(repeating: character, count: 2))
            tokens.append(String(repeating: character, count: 3))
        }
        if letters.count >= 2 {
            let first = String(letters[0])
            let second = String(letters[1])
            tokens.append(first + second)
            tokens.append(second + first)
        }
        let index = Int.random(in: 0..<tokens.count, using: &rng)
        return tokens[index]
    }
}

public struct RaceGame: Sendable {
    public let phrase: String
    public private(set) var index: Int
    public private(set) var mistakes: Int
    public private(set) var elapsed: TimeInterval
    public let paceCharactersPerSecond: Double
    public private(set) var finishedAt: TimeInterval?

    public init(phrase: String, paceCharactersPerSecond: Double = 0.85) {
        self.phrase = phrase
        self.index = 0
        self.mistakes = 0
        self.elapsed = 0
        self.paceCharactersPerSecond = paceCharactersPerSecond
        self.finishedAt = nil
    }

    public var isComplete: Bool {
        finishedAt != nil
    }

    public var playerProgress: Double {
        guard !phrase.isEmpty else { return 1 }
        return min(1, Double(index) / Double(phrase.count))
    }

    public var paceProgress: Double {
        guard !phrase.isEmpty else { return 1 }
        let characters = elapsed * paceCharactersPerSecond
        return min(1, characters / Double(phrase.count))
    }

    public var playerWon: Bool {
        guard let finishedAt else { return false }
        return finishedAt * paceCharactersPerSecond < Double(phrase.count)
    }

    public var accuracy: Double {
        let total = index + mistakes
        guard total > 0 else { return 1 }
        return Double(index) / Double(total)
    }

    public var nextCharacter: Character? {
        guard index < phrase.count else { return nil }
        let stringIndex = phrase.index(phrase.startIndex, offsetBy: index)
        return phrase[stringIndex]
    }

    public var paceIsAhead: Bool {
        paceProgress > playerProgress + 0.001 && !isComplete
    }

    public mutating func tick(delta: TimeInterval) {
        guard finishedAt == nil else { return }
        elapsed += max(delta, 0)
    }

    @discardableResult
    public mutating func type(_ character: Character) -> KeystrokeOutcome {
        guard finishedAt == nil, let expected = nextCharacter else { return .ignored }
        if character == expected {
            index += 1
            if index >= phrase.count {
                finishedAt = elapsed
                return .completed
            }
            return .correct
        }
        mistakes += 1
        return .incorrect
    }
}
