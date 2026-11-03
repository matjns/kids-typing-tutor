import SwiftUI
import TypingTutorCore

enum Theme {
    static let paper = Color(red: 0.99, green: 0.96, blue: 0.91)
    static let ink = Color(red: 0.16, green: 0.19, blue: 0.25)
    static let coral = Color(red: 0.90, green: 0.38, blue: 0.31)
    static let leaf = Color(red: 0.16, green: 0.55, blue: 0.44)
    static let sun = Color(red: 0.95, green: 0.72, blue: 0.22)
    static let sky = Color(red: 0.33, green: 0.58, blue: 0.82)
    static let card = Color.white
    static let mist = Color(red: 0.93, green: 0.90, blue: 0.84)
    static let peach = Color(red: 1.0, green: 0.90, blue: 0.80)

    static func fingerColor(_ finger: Finger) -> Color {
        switch finger {
        case .leftPinky: return Color(red: 0.84, green: 0.34, blue: 0.46)
        case .leftRing: return Color(red: 0.90, green: 0.50, blue: 0.24)
        case .leftMiddle: return Color(red: 0.84, green: 0.64, blue: 0.16)
        case .leftIndex: return Color(red: 0.22, green: 0.62, blue: 0.40)
        case .thumb: return Color(red: 0.16, green: 0.55, blue: 0.58)
        case .rightIndex: return Color(red: 0.24, green: 0.48, blue: 0.78)
        case .rightMiddle: return Color(red: 0.38, green: 0.42, blue: 0.76)
        case .rightRing: return Color(red: 0.54, green: 0.38, blue: 0.74)
        case .rightPinky: return Color(red: 0.72, green: 0.36, blue: 0.62)
        }
    }

    static func stageColor(_ stage: Stage) -> Color {
        switch stage {
        case .homeRow: return leaf
        case .topRow: return sky
        case .bottomRow: return sun
        case .shift: return coral
        case .numbers: return Color(red: 0.45, green: 0.40, blue: 0.78)
        case .punctuation: return Color(red: 0.86, green: 0.48, blue: 0.22)
        case .sentences: return Color(red: 0.18, green: 0.55, blue: 0.58)
        }
    }
}
