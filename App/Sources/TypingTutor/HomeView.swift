import SwiftUI
import TypingTutorCore

struct HomeView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                continueCard
                HStack(alignment: .top, spacing: 16) {
                    tile(
                        title: "Lesson path",
                        detail: "Home row, then one new row at a time.",
                        symbol: "book.fill",
                        fill: Theme.leaf
                    ) {
                        path.append(.path)
                    }
                    tile(
                        title: "Falling words",
                        detail: "Type a word before it reaches the ground.",
                        symbol: "arrow.down.circle.fill",
                        fill: Theme.sky
                    ) {
                        path.append(.falling)
                    }
                    tile(
                        title: "Race",
                        detail: "Beat the breeze to the finish line.",
                        symbol: "flag.fill",
                        fill: Theme.coral
                    ) {
                        path.append(.race)
                    }
                }
                Button {
                    path.append(.progress)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My progress")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.ink)
                            Text("\(model.progress.starTotal) stars · \(model.progress.lessonsWithStars) lessons · \(Badge.earned(from: model.progress).count) badges")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.ink.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink.opacity(0.45))
                    }
                    .padding(18)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
                if let warning = model.saveWarning {
                    Text(warning)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.coral)
                }
            }
            .padding(28)
            .frame(maxWidth: 1040, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(homeBackground)
        .navigationTitle("Typing Tutor")
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(model)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Greeting.homeTitle(name: model.progress.playerName))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.coral)
                Text("Typing Tutor")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text("Home row first. New keys come in slowly.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.72))
            }
            Spacer()
            Button {
                showSettings = true
            } label: {
                Label("Nickname", systemImage: "gearshape")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var continueCard: some View {
        let next = ProgressRules.nextLesson(in: model.progress)
        let stars = model.progress.bestStars[next.id] ?? 0
        let finishedAll = LessonCatalog.all.allSatisfy { (model.progress.bestStars[$0.id] ?? 0) > 0 }
        return Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(finishedAll ? "Practice again" : "Up next")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.leaf)
                Text(next.title)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(next.blurb)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.75))
                HStack(spacing: 12) {
                    Text(next.stage.title)
                    Text(minuteLabel(next.suggestedSeconds))
                    if stars > 0 {
                        StarRow(filled: stars)
                    }
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.65))
                BigButton(title: stars == 0 ? "Start" : "Play again") {
                    path.append(.exercise(next.id))
                }
            }
        }
    }

    private func tile(title: String, detail: String, symbol: String, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 52, height: 52)
                    .background(fill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func minuteLabel(_ seconds: Int) -> String {
        let minutes = max(1, Int((Double(seconds) / 60.0).rounded()))
        if minutes == 1 { return "About 1 minute" }
        return "About \(minutes) minutes"
    }

    private var homeBackground: some View {
        ZStack {
            Theme.paper
            Circle()
                .fill(Theme.sun.opacity(0.35))
                .frame(width: 220, height: 220)
                .offset(x: 360, y: -260)
                .allowsHitTesting(false)
            Circle()
                .fill(Theme.sky.opacity(0.22))
                .frame(width: 180, height: 180)
                .offset(x: -420, y: -220)
                .allowsHitTesting(false)
        }
    }
}
