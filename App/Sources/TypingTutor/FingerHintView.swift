import SwiftUI
import TypingTutorCore

struct FingerHintView: View {
    let character: Character?
    var notice: String?

    private var activeFinger: Finger? {
        character.map { KeyboardMap.finger(for: $0) }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            hand(side: "left")
            VStack(alignment: .leading, spacing: 4) {
                Text(headline)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            hand(side: "right")
        }
        .padding(14)
        .background(notice == nil ? Color.white : Theme.peach, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var headline: String {
        guard let activeFinger else { return "Ready when you are" }
        if activeFinger == .thumb {
            return "Either thumb"
        }
        return activeFinger.phrase.capitalized
    }

    private var detail: String {
        if let notice {
            return notice
        }
        guard let character else { return "The glowing key is next." }
        return KeyboardMap.coachLine(for: character)
    }

    private func hand(side: String) -> some View {
        let fingers: [Finger] = side == "left"
            ? [.leftPinky, .leftRing, .leftMiddle, .leftIndex]
            : [.rightIndex, .rightMiddle, .rightRing, .rightPinky]
        return HStack(alignment: .bottom, spacing: 5) {
            if side == "right" {
                fingerDot(.thumb)
            }
            ForEach(fingers, id: \.self) { finger in
                fingerDot(finger)
            }
            if side == "left" {
                fingerDot(.thumb)
            }
        }
    }

    private func fingerDot(_ finger: Finger) -> some View {
        let active = activeFinger == finger
        return Circle()
            .fill(active ? Theme.fingerColor(finger) : Theme.fingerColor(finger).opacity(0.28))
            .frame(width: active ? 22 : 14, height: active ? 22 : 14)
            .accessibilityHidden(true)
    }
}
