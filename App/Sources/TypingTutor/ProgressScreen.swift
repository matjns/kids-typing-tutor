import SwiftUI
import TypingTutorCore

struct ProgressScreen: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                BackButton { pop() }
                Text("My progress")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summary
                    trickyKeys
                    badges
                    recent
                }
                .padding(.bottom, 20)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.paper)
        .navigationBarBackButtonHidden(true)
    }

    private var summary: some View {
        HStack(spacing: 12) {
            StatPill(title: "Stars", value: "\(model.progress.starTotal)")
            StatPill(title: "Lessons", value: "\(model.progress.lessonsWithStars)/\(LessonCatalog.all.count)")
            StatPill(title: "Practice", value: DisplayFormat.practiceTime(model.progress.totalPracticeSeconds))
            StatPill(title: "Best catch", value: "\(model.progress.bestFallingScore)")
            StatPill(title: "Races won", value: "\(model.progress.racesWon)")
        }
    }

    private var trickyKeys: some View {
        let weak = model.coach.weakKeys(among: ProgressRules.unlockedKeys(progress: model.progress))
        return Card {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tricky keys")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                if weak.isEmpty {
                    Text("No tricky keys yet. They show up after a few misses.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                } else {
                    Text(weak.map { KeyboardMap.spokenName(for: $0) }.joined(separator: ", "))
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.coral)
                    BigButton(title: "Practice tricky keys", fill: Theme.leaf) {
                        path.append(.weakKeys)
                    }
                }
            }
        }
    }

    private var badges: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Badges")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 12)], spacing: 12) {
                ForEach(Badge.all) { badge in
                    badgeCard(badge)
                }
            }
        }
    }

    private func badgeCard(_ badge: Badge) -> some View {
        let earned = Badge.isEarned(badge.id, progress: model.progress)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: earned ? "star.fill" : "star")
                    .foregroundStyle(earned ? Theme.sun : Theme.ink.opacity(0.3))
                Text(earned ? "Earned" : "Not yet")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(earned ? Theme.leaf : Theme.ink.opacity(0.45))
            }
            Text(badge.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text(badge.detail)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(earned ? Color.white : Theme.mist, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel("\(badge.title). \(earned ? "Earned" : "Not yet"). \(badge.detail)")
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent tries")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            if model.progress.history.isEmpty {
                Text("Your stars will show up here after the first lesson.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.ink.opacity(0.7))
            } else {
                ForEach(Array(model.progress.history.suffix(5).reversed().enumerated()), id: \.offset) { pair in
                    let attempt = pair.element
                    HStack {
                        Text(title(for: attempt.lessonID))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        StarRow(filled: attempt.stars)
                        Text(DisplayFormat.percent(attempt.accuracy, attempts: 1))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.ink.opacity(0.65))
                            .frame(width: 52, alignment: .trailing)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func title(for lessonID: String) -> String {
        if lessonID == "weak-keys" { return "Tricky keys" }
        return LessonCatalog.lesson(id: lessonID)?.title ?? "Practice"
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
