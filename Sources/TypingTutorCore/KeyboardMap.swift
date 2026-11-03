import Foundation

public enum ShiftSide: String, Equatable, Sendable {
    case left
    case right

    public var word: String {
        switch self {
        case .left: return "left"
        case .right: return "right"
        }
    }
}

public struct KeyCap: Equatable, Identifiable, Sendable {
    public enum Role: Equatable, Sendable {
        case character(Character)
        case shift(ShiftSide)
        case space
    }

    public let id: String
    public let label: String
    public let role: Role
    public let finger: Finger
    /// Relative width on its row. Shift keys are wider than letter keys.
    public let flex: Double

    public var character: Character? {
        switch role {
        case .character(let character):
            return character
        case .space:
            return " "
        case .shift:
            return nil
        }
    }

    public init(id: String, label: String, role: Role, finger: Finger, flex: Double = 1) {
        self.id = id
        self.label = label
        self.role = role
        self.finger = finger
        self.flex = flex
    }
}

/// QWERTY finger map used by the lessons and the on-screen keyboard.
public enum KeyboardMap {
    public static func spokenName(for character: Character) -> String {
        switch character {
        case " ": return "space"
        case ".": return "period"
        case ",": return "comma"
        case "?": return "question mark"
        case "!": return "exclamation mark"
        case "'": return "apostrophe"
        case "\"": return "quote"
        case ";": return "semicolon"
        case "/": return "slash"
        default:
            return String(character).uppercased()
        }
    }

    public static func needsShift(_ character: Character) -> Bool {
        if let scalar = character.unicodeScalars.first, CharacterSet.uppercaseLetters.contains(scalar), character.isLetter {
            return true
        }
        return shiftToBase[character] != nil
    }

    public static func baseKey(for character: Character) -> Character {
        if let base = shiftToBase[character] {
            return base
        }
        if character.isLetter {
            let lowered = String(character).lowercased()
            if let first = lowered.first {
                return first
            }
        }
        return character
    }

    public static func finger(for character: Character) -> Finger {
        let base = baseKey(for: character)
        return fingerByBase[base] ?? .rightPinky
    }

    /// Shift is pressed with the other hand, so the letter finger stays free.
    public static func oppositeShift(for character: Character) -> ShiftSide? {
        guard needsShift(character) else { return nil }
        switch finger(for: character).hand {
        case "left":
            return .right
        case "right":
            return .left
        default:
            return .left
        }
    }

    public static func coachLine(for character: Character) -> String {
        let name = spokenName(for: character)
        let fingerPhrase = finger(for: character).phrase
        if let side = oppositeShift(for: character) {
            let shiftFinger = side == .left ? "left pinky finger" : "right pinky finger"
            return "Hold \(side.word) shift with your \(shiftFinger). Press \(name) with your \(fingerPhrase)."
        }
        return "Press \(name) with your \(fingerPhrase)."
    }

    public static let rows: [[KeyCap]] = [
        numberRow,
        Array("qwertyuiop").map { letter($0, fingerByBase[$0] ?? .rightPinky) },
        (Array("asdfghjkl;") + ["'"]).map { letter($0, fingerByBase[$0] ?? .rightPinky) },
        bottomRow,
        [
            KeyCap(id: "space", label: "space", role: .space, finger: .thumb, flex: 1)
        ]
    ]

    private static let numberRow: [KeyCap] = Array("1234567890").map { digit in
        letter(digit, fingerByBase[digit] ?? .leftPinky)
    }

    private static let bottomRow: [KeyCap] = [
        KeyCap(id: "shift-left", label: "shift", role: .shift(.left), finger: .leftPinky, flex: 1.8)
    ] + Array("zxcvbnm,./").map { letter($0, fingerByBase[$0] ?? .rightPinky) } + [
        KeyCap(id: "shift-right", label: "shift", role: .shift(.right), finger: .rightPinky, flex: 1.8)
    ]

    private static func letter(_ character: Character, _ finger: Finger) -> KeyCap {
        KeyCap(
            id: "key-\(character)",
            label: String(character),
            role: .character(character),
            finger: finger,
            flex: 1
        )
    }

    private static let shiftToBase: [Character: Character] = [
        "!": "1", "@": "2", "#": "3", "$": "4", "%": "5",
        "^": "6", "&": "7", "*": "8", "(": "9", ")": "0",
        ":": ";", "\"": "'",
        "<": ",", ">": ".", "?": "/"
    ]

    private static let fingerByBase: [Character: Finger] = [
        "1": .leftPinky, "2": .leftRing, "3": .leftMiddle, "4": .leftIndex, "5": .leftIndex,
        "6": .rightIndex, "7": .rightIndex, "8": .rightMiddle, "9": .rightRing, "0": .rightPinky,
        "q": .leftPinky, "w": .leftRing, "e": .leftMiddle, "r": .leftIndex, "t": .leftIndex,
        "y": .rightIndex, "u": .rightIndex, "i": .rightMiddle, "o": .rightRing, "p": .rightPinky,
        "a": .leftPinky, "s": .leftRing, "d": .leftMiddle, "f": .leftIndex, "g": .leftIndex,
        "h": .rightIndex, "j": .rightIndex, "k": .rightMiddle, "l": .rightRing, ";": .rightPinky,
        "'": .rightPinky,
        "z": .leftPinky, "x": .leftRing, "c": .leftMiddle, "v": .leftIndex, "b": .leftIndex,
        "n": .rightIndex, "m": .rightIndex, ",": .rightMiddle, ".": .rightRing, "/": .rightPinky,
        " ": .thumb
    ]
}
