import Foundation

public enum GentleFeedback {
    public static let bannedSnippets = ["wrong", "bad", "fail", "stupid", "loser", "dummy", "hate"]

    public static func message(expected: Character, typed: Character) -> String {
        let name = KeyboardMap.spokenName(for: expected)
        let finger = KeyboardMap.finger(for: expected).phrase
        if expected.isLetter && expected.isLowercase && String(typed) == String(expected).uppercased() {
            return "Caps lock might be on. Next is \(name). Use your \(finger)."
        }
        if expected.isLetter && expected.isUppercase && String(typed) == String(expected).lowercased() {
            let side = KeyboardMap.oppositeShift(for: expected)?.word ?? "other"
            return "Almost! Hold the \(side) shift for \(name). Use your \(finger) to press the letter."
        }
        let leads = ["Almost!", "Nice try.", "So close.", "Good effort."]
        let leadIndex = Int(expected.asciiValue ?? 0) % leads.count
        return "\(leads[leadIndex]) Next is \(name). Use your \(finger)."
    }
}

public enum Encouragement {
    public static func lessonComplete(stars: Int) -> String {
        switch stars {
        case 3: return "Wonderful. Three stars."
        case 2: return "Nice work. Two stars."
        default: return "You finished. One star."
        }
    }

    public static func raceFinish(won: Bool) -> String {
        if won {
            return "You beat the breeze!"
        }
        return "You finished the race. The breeze was quick today."
    }

    public static func fallingOver(score: Int, balloonsLeft: Int) -> String {
        if balloonsLeft > 0 {
            return "Time is up. You scored \(score)."
        }
        return "The words reached the ground. You scored \(score)."
    }

    public static func paceNote(paceAhead: Bool) -> String {
        if paceAhead {
            return "The breeze is ahead. Keep going. You can still finish."
        }
        return "You are ahead of the breeze."
    }
}
