import SwiftUI
import TypingTutorCore

struct LessonPathView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var path: [Screen]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                BackButton { pop() }
                Text("Lesson path")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }
            Text("Tap any open lesson to play it again. Your stars stay safe.")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.7))
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(Stage.allCases, id: \.self) { stage in
                        stageBlock(stage)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.paper)
        .navigationBarBackButtonHidden(true)
    }

    private func stageBlock(_ stage: Stage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Theme.stageColor(stage))
                    .frame(width: 14, height: 14)
                Text(stage.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
            }
            Text(stage.detail)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.ink.opacity(0.65))
            ForEach(LessonCatalog.lessons(in: stage)) { lesson in
                lessonRow(lesson)
            }
        }
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        let unlocked = ProgressRules.isUnlocked(lesson: lesson, progress: model.progress)
        let stars = model.progress.bestStars[lesson.id] ?? 0
        return Button {
            path.append(.exercise(lesson.id))
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                    Text(unlocked ? lesson.blurb : "Finish an earlier lesson to open this one.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.ink.opacity(0.62))
                        .lineLimit(2)
                    if unlocked, !lesson.newKeys.isEmpty {
                        Text(DisplayFormat.keyList(lesson.newKeys))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.stageColor(lesson.stage))
                    }
                }
                Spacer()
                if unlocked {
                    StarRow(filled: stars)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(Theme.ink.opacity(0.35))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(Color.white.opacity(unlocked ? 1 : 0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .accessibilityLabel(unlocked ? "\(lesson.title), \(stars) stars" : "\(lesson.title), locked")
    }

    private func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
