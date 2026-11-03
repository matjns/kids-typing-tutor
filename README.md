# Typing Tutor

Typing Tutor is a Mac app for a learner about 9 years old. It starts on the home row and adds keys a few at a time: top row, bottom row, shift and capitals, numbers, then punctuation and short sentences. An on-screen keyboard shows the next key and which finger to use. Words per minute and accuracy update while you type.

It also has two short games, Falling words and Race, plus stars and badges. If a key is missed a few times, later exercises mix that key back in.

The app is offline. There is no account, no ads, and no network. A nickname is optional and starts blank.

The bundle id is `com.kidscomputer.typingtutor`.

## Download and install

The Mac download is the universal app zip on the v1.0.0 release:

[TypingTutor-mac-universal.zip](https://github.com/matjns/kids-typing-tutor/releases/download/v1.0.0/TypingTutor-mac-universal.zip)

That file is attached when the `v1.0.0` tag is published. The same release includes `README-mac.txt`.

1. Download the zip and unzip it.
2. Move `Typing Tutor.app` to the Applications folder.
3. The first time, Control-click the app and choose Open, then Open again. macOS does this because the copy is unsigned.
4. If macOS says the app is damaged, run `xattr -cr "/Applications/Typing Tutor.app"` in Terminal, then Control-click and choose Open again.

More of the same steps are in `README-mac.txt` inside the zip.

## How it fits with Kids Computer

The Kids Computer launcher starts this app by bundle id (`com.kidscomputer.typingtutor`). Typing Tutor is a normal app: it does not hide the Dock or take over the menu. Close the window, or press Command-Q, and the app quits so the launcher can come back.

You can also open Typing Tutor by itself from the Applications folder.

## Progress

Stars, badges, tricky-key notes, and the optional nickname are saved on this Mac in:

`~/Library/Application Support/Typing Tutor/progress.json`

The sandboxed App Store build uses the same folder name inside the app container. The app asks macOS for the Application Support folder, so it does not need a special path.

## Build on a Mac

You need macOS 14 or newer, with Xcode installed so the `swift` command exists.

```bash
./build.sh test
./build.sh
```

`./build.sh test` runs the lesson, scoring, and game tests. `./build.sh` makes `dist/TypingTutor-mac-universal.zip` (Apple silicon and Intel in one app) and `dist/README-mac.txt`.

The tests only need Swift. They also run on Linux. The window itself is SwiftUI, so the app is built on a Mac. GitHub Actions does that on every push.

## Project layout

- `Sources/TypingTutorCore` is the lessons, scoring, games, and saved progress. No SwiftUI.
- `Tests/TypingTutorCoreTests` checks that logic.
- `App/Sources/TypingTutor` is the Mac window.
- `TypingTutor.xcodeproj` is the Xcode project used for an App Store archive.
- `docs/APP_STORE.md` lists what is left before an App Store submission.

## Privacy

Nothing is collected. There is no login and no analytics. Do not put a child's real name into the nickname field if this Mac is shared or if you copy the progress file anywhere.

## License

MIT. Copyright 2026 matjns. See `LICENSE`.
