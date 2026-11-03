import Foundation

/// Which finger presses a key. Phrases are read aloud in the on-screen hint.
public enum Finger: String, Codable, CaseIterable, Sendable {
    case leftPinky
    case leftRing
    case leftMiddle
    case leftIndex
    case rightIndex
    case rightMiddle
    case rightRing
    case rightPinky
    case thumb

    public var phrase: String {
        switch self {
        case .leftPinky: return "left pinky finger"
        case .leftRing: return "left ring finger"
        case .leftMiddle: return "left middle finger"
        case .leftIndex: return "left index finger"
        case .rightIndex: return "right index finger"
        case .rightMiddle: return "right middle finger"
        case .rightRing: return "right ring finger"
        case .rightPinky: return "right pinky finger"
        case .thumb: return "thumb"
        }
    }

    /// "left", "right", or "either". Used to pick the opposite shift key.
    public var hand: String {
        switch self {
        case .leftPinky, .leftRing, .leftMiddle, .leftIndex:
            return "left"
        case .rightIndex, .rightMiddle, .rightRing, .rightPinky:
            return "right"
        case .thumb:
            return "either"
        }
    }
}
