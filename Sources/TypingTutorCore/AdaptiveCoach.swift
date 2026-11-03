import Foundation

public struct KeyStat: Codable, Equatable, Sendable {
    public var seen: Int
    public var missed: Int

    public init(seen: Int = 0, missed: Int = 0) {
        self.seen = seen
        self.missed = missed
    }

    public var accuracy: Double {
        guard seen > 0 else { return 1 }
        let hits = max(0, seen - missed)
        return Double(hits) / Double(seen)
    }
}

/// Remembers which keys were missed so the next exercise can repeat them.
public struct AdaptiveCoach: Equatable, Sendable {
    public private(set) var stats: [String: KeyStat]

    public init(stats: [String: KeyStat] = [:]) {
        self.stats = stats
    }

    public mutating func record(expected: Character, wasCorrect: Bool) {
        let key = String(expected)
        var stat = stats[key] ?? KeyStat()
        stat.seen += 1
        if !wasCorrect {
            stat.missed += 1
        }
        stats[key] = stat
    }

    public func weakKeys(
        among allowed: Set<Character>,
        threshold: Double = 0.86,
        minimumSeen: Int = 4
    ) -> [Character] {
        var ranked: [(Character, Double)] = []
        for character in allowed where character != " " {
            guard let stat = stats[String(character)], stat.seen >= minimumSeen else { continue }
            if stat.accuracy < threshold {
                ranked.append((character, stat.accuracy))
            }
        }
        ranked.sort { lhs, rhs in
            if lhs.1 == rhs.1 {
                return String(lhs.0) < String(rhs.0)
            }
            return lhs.1 < rhs.1
        }
        return ranked.map(\.0)
    }
}
