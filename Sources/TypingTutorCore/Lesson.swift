import Foundation

public enum ExerciseMode: String, Equatable, Sendable {
    case drill
    case words
    case lines
}

public enum Stage: String, Codable, CaseIterable, Sendable {
    case homeRow
    case topRow
    case bottomRow
    case shift
    case numbers
    case punctuation
    case sentences

    public var title: String {
        switch self {
        case .homeRow: return "Home row"
        case .topRow: return "Top row"
        case .bottomRow: return "Bottom row"
        case .shift: return "Shift and capitals"
        case .numbers: return "Numbers"
        case .punctuation: return "Punctuation"
        case .sentences: return "Sentences"
        }
    }

    public var detail: String {
        switch self {
        case .homeRow: return "Start with the bump keys and the rest of the middle row."
        case .topRow: return "Reach up. Keep your other fingers parked."
        case .bottomRow: return "Reach down for the lowest letters."
        case .shift: return "One pinky holds shift. The other hand types the letter."
        case .numbers: return "The number row sits above the letters."
        case .punctuation: return "Marks that finish a thought."
        case .sentences: return "Real sentences made from the keys you know."
        }
    }

    public var order: Int {
        switch self {
        case .homeRow: return 0
        case .topRow: return 1
        case .bottomRow: return 2
        case .shift: return 3
        case .numbers: return 4
        case .punctuation: return 5
        case .sentences: return 6
        }
    }
}

public struct Lesson: Equatable, Identifiable, Sendable {
    public let id: String
    public let stage: Stage
    public let title: String
    public let blurb: String
    public let newKeys: [Character]
    public let allowedKeys: [Character]
    public let mode: ExerciseMode
    public let suggestedSeconds: Int
    public let samples: [String]

    public var typingCharacters: Set<Character> {
        Set(allowedKeys).union([" "])
    }

    public init(
        id: String,
        stage: Stage,
        title: String,
        blurb: String,
        newKeys: [Character],
        allowedKeys: [Character],
        mode: ExerciseMode,
        suggestedSeconds: Int,
        samples: [String]
    ) {
        self.id = id
        self.stage = stage
        self.title = title
        self.blurb = blurb
        self.newKeys = newKeys
        self.allowedKeys = allowedKeys
        self.mode = mode
        self.suggestedSeconds = suggestedSeconds
        self.samples = samples
    }
}
