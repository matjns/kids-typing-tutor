import SwiftUI
import TypingTutorCore

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.ink.opacity(0.06), lineWidth: 1)
            )
    }
}

struct BigButton: View {
    let title: String
    var fill: Color = Theme.coral
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .background(fill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.58))
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Theme.mist, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct StarRow: View {
    let filled: Int
    var total: Int = 3

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: index < filled ? "star.fill" : "star")
                    .foregroundStyle(Theme.sun)
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .accessibilityLabel("\(filled) of \(total) stars")
    }
}

/// A big, friendly button for moving between lessons.
struct LessonNavButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .background(Color.white, in: Capsule())
            .overlay(Capsule().stroke(Theme.ink.opacity(0.12), lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

enum DisplayFormat {
    static func clock(_ elapsed: TimeInterval) -> String {
        let total = max(0, Int(elapsed.rounded(.down)))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    static func percent(_ value: Double, attempts: Int) -> String {
        guard attempts > 0 else { return "—" }
        return "\(Int((value * 100).rounded()))%"
    }

    static func wordsPerMinute(_ value: Double, elapsed: TimeInterval) -> String {
        guard elapsed >= 1 else { return "—" }
        return "\(Int(value.rounded()))"
    }

    static func practiceTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes < 1 { return "0 min" }
        if minutes == 1 { return "1 min" }
        return "\(minutes) min"
    }

    static func keyList(_ keys: [Character]) -> String {
        let shown = keys.prefix(8).map { KeyboardMap.spokenName(for: $0) }
        if keys.count > 8 {
            return shown.joined(separator: ", ") + ", and more"
        }
        return shown.joined(separator: ", ")
    }
}

struct PromptText: View {
    let target: String
    let index: Int

    var body: some View {
        Text(styled)
            .font(.system(size: 32, weight: .semibold, design: .rounded))
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(accessibilityText)
    }

    private var styled: AttributedString {
        var result = AttributedString()
        for (offset, character) in target.enumerated() {
            var piece = AttributedString(String(character))
            if offset < index {
                piece.foregroundColor = Theme.leaf
            } else if offset == index {
                piece.foregroundColor = Theme.coral
                piece.underlineStyle = .single
            } else {
                piece.foregroundColor = Theme.ink.opacity(0.38)
            }
            result.append(piece)
        }
        return result
    }

    private var accessibilityText: String {
        let next = index < target.count ? KeyboardMap.spokenName(for: target[target.index(target.startIndex, offsetBy: index)]) : "done"
        return "Letter \(min(index + 1, target.count)) of \(target.count). Next is \(next)."
    }
}
