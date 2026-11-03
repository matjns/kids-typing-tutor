import Foundation

/// Nicknames are optional. Blank stays blank.
public enum PlayerName {
    public static let maximumLength = 16

    public static func cleaned(_ raw: String) -> String {
        let noBreaks = raw
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
        let collapsed = noBreaks
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .joined(separator: " ")
        return String(collapsed.prefix(maximumLength))
    }
}

public enum Greeting {
    public static func homeTitle(name: String) -> String {
        let cleaned = PlayerName.cleaned(name)
        if cleaned.isEmpty {
            return "Hi there"
        }
        return "Hi, \(cleaned)"
    }
}
