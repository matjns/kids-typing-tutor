import SwiftUI
import TypingTutorCore

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var confirmReset = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Nickname")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text("Optional. Leave this blank and the app will just say hello.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.7))
            TextField("Optional nickname", text: $draft)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .accessibilityLabel("Optional nickname. Leave blank to skip.")
                .onSubmit {
                    model.setPlayerName(draft)
                }
            BigButton(title: "Save nickname") {
                model.setPlayerName(draft)
                dismiss()
            }
            Button("Start fresh") {
                confirmReset = true
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(Theme.coral)
            .buttonStyle(.plain)
            Spacer()
            Text("Typing Tutor 1.0.0. Works offline. Nothing is sent anywhere.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.55))
        }
        .padding(28)
        .frame(width: 460, height: 420)
        .background(Theme.paper)
        .onAppear {
            draft = model.progress.playerName
        }
        .confirmationDialog("Start fresh?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Erase stars and start over", role: .destructive) {
                model.resetProgress()
                draft = ""
            }
            Button("Keep my progress", role: .cancel) {}
        } message: {
            Text("Stars, badges, and the nickname will be cleared on this Mac.")
        }
    }
}
