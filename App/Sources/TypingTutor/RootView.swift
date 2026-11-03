import SwiftUI
import TypingTutorCore

enum Screen: Hashable {
    case path
    case exercise(String)
    case weakKeys
    case falling
    case race
    case progress
}

struct RootView: View {
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: Screen.self) { screen in
                    destination(screen)
                }
        }
        .tint(Theme.coral)
        .background(Theme.paper)
    }

    @ViewBuilder
    private func destination(_ screen: Screen) -> some View {
        switch screen {
        case .path:
            LessonPathView(path: $path)
        case .exercise(let id):
            if let lesson = LessonCatalog.lesson(id: id) {
                ExerciseView(lesson: lesson, path: $path)
            } else {
                MissingScreen(path: $path)
            }
        case .weakKeys:
            WeakKeysView(path: $path)
        case .falling:
            FallingWordsView(path: $path)
        case .race:
            RaceView(path: $path)
        case .progress:
            ProgressScreen(path: $path)
        }
    }
}

struct MissingScreen: View {
    @Binding var path: [Screen]

    var body: some View {
        VStack(spacing: 16) {
            Text("That lesson is not on the path.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            BigButton(title: "Home") {
                path.removeAll()
            }
            .frame(maxWidth: 280)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.paper)
        .navigationBarBackButtonHidden(true)
    }
}
