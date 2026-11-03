import Foundation

public struct Exercise: Equatable, Sendable {
    public let lessonID: String
    public let title: String
    public let prompt: String
    public let suggestedSeconds: Int
    public let focusKeys: [Character]
    public let includesWeakKeyPractice: Bool

    public init(
        lessonID: String,
        title: String,
        prompt: String,
        suggestedSeconds: Int,
        focusKeys: [Character],
        includesWeakKeyPractice: Bool
    ) {
        self.lessonID = lessonID
        self.title = title
        self.prompt = prompt
        self.suggestedSeconds = suggestedSeconds
        self.focusKeys = focusKeys
        self.includesWeakKeyPractice = includesWeakKeyPractice
    }

    public var lengthLabel: String {
        let minutes = max(1, Int((Double(suggestedSeconds) / 60.0).rounded()))
        if minutes == 1 {
            return "About 1 minute"
        }
        return "About \(minutes) minutes"
    }
}

public enum ExerciseGenerator {
    public static func targetLength(forSuggestedSeconds seconds: Int) -> Int {
        if seconds <= 75 { return 48 }
        if seconds <= 135 { return 96 }
        return 150
    }

    public static func make(lesson: Lesson, weakKeys: [Character], seed: UInt64) -> Exercise {
        var rng = SplitMix64(state: seed == 0 ? 0xC0FFEE : seed)
        let allowedList = unique(lesson.allowedKeys)
        let allowed = Set(allowedList).union([" "])
        let weak = unique(weakKeys.filter { allowed.contains($0) && $0 != " " })
        let count = targetLength(forSuggestedSeconds: lesson.suggestedSeconds)
        let body = bodyText(lesson: lesson, allowed: allowed, allowedList: allowedList, weak: weak, count: count, rng: &rng)

        var prompt = body
        if !weak.isEmpty {
            let warmupLength = min(18, max(8, count / 5))
            let warmup = drill(keys: weak, emphasize: weak, length: warmupLength, rng: &rng)
            prompt = warmup + " " + body
        }
        prompt = tidy(prompt)
        if prompt.isEmpty {
            let fallbackKeys = allowedList.isEmpty ? [Character("f"), Character("j")] : allowedList
            prompt = tidy(drill(keys: fallbackKeys, emphasize: [], length: count, rng: &rng))
        }

        let included = weak.contains { prompt.contains($0) }
        return Exercise(
            lessonID: lesson.id,
            title: lesson.title,
            prompt: prompt,
            suggestedSeconds: lesson.suggestedSeconds,
            focusKeys: weak.isEmpty ? lesson.newKeys : weak,
            includesWeakKeyPractice: !weak.isEmpty && included
        )
    }

    public static func racePhrase(allowed: Set<Character>, seed: UInt64) -> String {
        var rng = SplitMix64(state: seed == 0 ? 0xBEE5 : seed)
        let letters = allowed.filter { $0.isLetter && $0.isLowercase }
        let length = letters.count < 8 ? 36 : 84
        let phrase = tidy(words(allowed: allowed.union([" "]), emphasize: [], length: length, rng: &rng))
        if phrase.isEmpty {
            return tidy(drill(keys: Array(letters), emphasize: [], length: length, rng: &rng))
        }
        return phrase
    }

    public static func weakKeyExercise(allowed: Set<Character>, weakKeys: [Character], seed: UInt64) -> Exercise? {
        let keys = unique(Array(allowed.filter { $0 != " " }))
        let weak = unique(weakKeys.filter { allowed.contains($0) && $0 != " " })
        guard !weak.isEmpty else { return nil }
        let lesson = Lesson(
            id: "weak-keys",
            stage: .homeRow,
            title: "Tricky keys",
            blurb: "A short extra round for keys that need more practice.",
            newKeys: [],
            allowedKeys: keys,
            mode: .words,
            suggestedSeconds: 90,
            samples: []
        )
        return make(lesson: lesson, weakKeys: weak, seed: seed)
    }

    private static func bodyText(
        lesson: Lesson,
        allowed: Set<Character>,
        allowedList: [Character],
        weak: [Character],
        count: Int,
        rng: inout SplitMix64
    ) -> String {
        switch lesson.mode {
        case .drill:
            let emphasize = lesson.newKeys.isEmpty ? weak : lesson.newKeys
            return drill(keys: allowedList, emphasize: emphasize, length: count, rng: &rng)
        case .words:
            let emphasize = unique(lesson.newKeys + weak)
            return words(allowed: allowed, emphasize: emphasize, length: count, rng: &rng)
        case .lines:
            return lines(samples: lesson.samples, allowed: allowed, length: count, rng: &rng)
        }
    }

    static func drill(keys: [Character], emphasize: [Character], length: Int, rng: inout SplitMix64) -> String {
        let pool = unique(keys.filter { $0 != " " })
        let focus = unique(emphasize.filter { pool.contains($0) })
        let sourcePool = pool.isEmpty ? [Character("f"), Character("j")] : pool
        var pieces: [String] = []
        var lengthSoFar = 0
        var safety = 0
        while lengthSoFar < length && safety < 400 {
            safety += 1
            let useFocus = !focus.isEmpty && Int.random(in: 0..<3, using: &rng) != 0
            let source = useFocus ? focus : sourcePool
            let key = source[Int.random(in: 0..<source.count, using: &rng)]
            let reps = Int.random(in: 2...4, using: &rng)
            let chunk = String(repeating: String(key), count: reps)
            let extra = pieces.isEmpty ? chunk.count : chunk.count + 1
            if lengthSoFar > 0 && lengthSoFar + extra > length + 6 {
                break
            }
            pieces.append(chunk)
            lengthSoFar += extra
        }
        return pieces.joined(separator: " ")
    }

    static func words(allowed: Set<Character>, emphasize: [Character], length: Int, rng: inout SplitMix64) -> String {
        let pool = WordBank.words.filter { word in
            word.count >= 2 && word.allSatisfy { allowed.contains($0) }
        }
        if pool.isEmpty {
            let letters = Array(allowed.filter { $0 != " " })
            return drill(keys: letters, emphasize: emphasize, length: length, rng: &rng)
        }
        let preferred = pool.filter { word in word.contains { emphasize.contains($0) } }
        var pieces: [String] = []
        var lengthSoFar = 0
        var safety = 0
        while lengthSoFar < length && safety < 400 {
            safety += 1
            let usePreferred = !preferred.isEmpty && Int.random(in: 0..<4, using: &rng) != 0
            let source = usePreferred ? preferred : pool
            let word = source[Int.random(in: 0..<source.count, using: &rng)]
            let extra = pieces.isEmpty ? word.count : word.count + 1
            if lengthSoFar > 0 && lengthSoFar + extra > length + 10 {
                break
            }
            pieces.append(word)
            lengthSoFar += extra
        }
        return pieces.joined(separator: " ")
    }

    static func lines(samples: [String], allowed: Set<Character>, length: Int, rng: inout SplitMix64) -> String {
        let pool = samples.filter { sample in
            !sample.isEmpty && sample.allSatisfy { allowed.contains($0) }
        }
        if pool.isEmpty {
            return words(allowed: allowed, emphasize: [], length: length, rng: &rng)
        }
        var order = pool
        var index = order.count
        while index > 1 {
            index -= 1
            let swapIndex = Int.random(in: 0...index, using: &rng)
            order.swapAt(index, swapIndex)
        }
        var pieces: [String] = []
        var lengthSoFar = 0
        var cursor = 0
        while lengthSoFar < length && cursor < order.count * 3 {
            let sample = order[cursor % order.count]
            let extra = pieces.isEmpty ? sample.count : sample.count + 1
            if lengthSoFar > 0 && lengthSoFar + extra > length + 24 {
                break
            }
            pieces.append(sample)
            lengthSoFar += extra
            cursor += 1
        }
        if pieces.isEmpty, let first = order.first {
            return first
        }
        return pieces.joined(separator: " ")
    }

    static func tidy(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).map(String.init).joined(separator: " ")
    }

    static func unique(_ chars: [Character]) -> [Character] {
        var seen = Set<Character>()
        var result: [Character] = []
        for character in chars where seen.insert(character).inserted {
            result.append(character)
        }
        return result
    }
}
