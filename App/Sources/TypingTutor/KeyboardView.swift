import SwiftUI
import TypingTutorCore

struct KeyboardView: View {
    let highlight: Character?
    var onType: (Character) -> Void

    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(KeyboardMap.rows.enumerated()), id: \.offset) { pair in
                keyboardRow(pair.element)
                    .frame(height: 50)
            }
        }
        .padding(12)
        .background(Theme.mist, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func keyboardRow(_ row: [KeyCap]) -> some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 6
            let totalFlex = row.reduce(0.0) { $0 + $1.flex }
            let gaps = spacing * CGFloat(max(row.count - 1, 0))
            let unit = max(1, (proxy.size.width - gaps) / CGFloat(totalFlex))
            HStack(spacing: spacing) {
                ForEach(row) { key in
                    keyButton(key)
                        .frame(width: unit * CGFloat(key.flex), height: proxy.size.height)
                }
            }
        }
    }

    private func keyButton(_ key: KeyCap) -> some View {
        let active = isActive(key)
        return Button {
            if let character = typedCharacter(for: key) {
                onType(character)
            }
        } label: {
            Text(label(for: key))
                .font(.system(size: key.role == .space ? 16 : 18, weight: .bold, design: .rounded))
                .foregroundStyle(active ? Color.white : Theme.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(active ? Theme.coral : Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(active ? Theme.coral : Theme.fingerColor(key.finger), lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText(for: key, active: active))
    }

    private func isActive(_ key: KeyCap) -> Bool {
        guard let highlight else { return false }
        switch key.role {
        case .space:
            return highlight == " "
        case .shift(let side):
            return KeyboardMap.oppositeShift(for: highlight) == side
        case .character(let character):
            return KeyboardMap.baseKey(for: highlight) == character
        }
    }

    private func label(for key: KeyCap) -> String {
        if case .character(let character) = key.role,
           let highlight,
           KeyboardMap.baseKey(for: highlight) == character {
            return String(highlight)
        }
        return key.label
    }

    private func typedCharacter(for key: KeyCap) -> Character? {
        switch key.role {
        case .space:
            return " "
        case .shift:
            return nil
        case .character(let character):
            if let highlight, KeyboardMap.baseKey(for: highlight) == character {
                return highlight
            }
            return character
        }
    }

    private func accessibilityText(for key: KeyCap, active: Bool) -> String {
        let name = label(for: key)
        let finger = key.finger.phrase
        if active {
            return "\(name), next key, \(finger)"
        }
        return "\(name), \(finger)"
    }
}
