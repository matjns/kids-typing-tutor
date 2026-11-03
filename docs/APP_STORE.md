# App Store steps still left

Typing Tutor is set up so it can be submitted to the Mac App Store. These steps still need a person with an Apple Developer account. They cannot be finished from the source zip alone.

## Already in the project

- Bundle id: `com.kidscomputer.typingtutor`
- Display name: Typing Tutor
- Version 1.0.0 (build 1), in `App/Info.plist` and in the Xcode target
- Minimum system: macOS 14
- Category: Education
- App icon: `App/Resources/Assets.xcassets` and `App/Resources/AppIcon.iconset`
- Sandbox entitlements: `App/TypingTutor.entitlements` (App Sandbox on, no network, no special files)
- `ITSAppUsesNonExemptEncryption` is false (no custom encryption)
- No private APIs, no analytics, no accounts, no ads
- The unsigned zip from `./build.sh` is for direct download. It is not signed with the sandbox entitlement. Gatekeeper steps are in `README-mac.txt`.

## 1. Signing

1. Open `TypingTutor.xcodeproj` in Xcode 16 or newer.
2. Select the TypingTutor target.
3. Signing & Capabilities: choose your Team.
4. Confirm the bundle id is still `com.kidscomputer.typingtutor`.
5. Confirm App Sandbox is on and Incoming/Outgoing network is off. The entitlements file is the source of that.

Xcode will create a provisioning profile when you archive.

## 2. Archive and upload

1. Set the scheme to TypingTutor and the run destination to Any Mac.
2. Product > Archive.
3. In the Organizer, Distribute App > App Store Connect > Upload.
4. For each upload, bump the build number (`CFBundleVersion` / Current Project Version) so it is higher than the last upload. Leave the marketing version at 1.0.0 until you want a new version.

You can also run `./build.sh` to make an unsigned universal app for a Mac that is not using the App Store. That zip is what the GitHub Release ships. Do not upload the unsigned zip to App Store Connect. Upload the archive from Xcode.

## 3. Privacy nutrition label

Data collection: **Data Not Collected**.

The app does not use the network. The optional nickname and practice stats stay in Application Support on the Mac (inside the sandbox container for the App Store build). Do not add analytics, crash reporters, or accounts later without changing this label.

Age rating: 4+ is appropriate. There are no purchases, no unrestricted web, and no user-generated public sharing.

## 4. Screenshots and listing

App Store Connect needs screenshots of the Mac app. Capture these on a Mac after a clean run (nickname left blank):

- Home screen, before any lesson is finished
- A lesson with the on-screen keyboard glowing on the next key
- The star screen at the end of a lesson
- My progress, including at least one badge and the tricky-keys area
- Falling words or Race

Do not include a child's name, photo, or school in the screenshots or the description.

Suggested subtitle: "Home row first, one new key at a time."

Description ideas to cover: short lessons, finger hints, words per minute, accuracy, stars, Falling words, and Race. Say that it works offline.

## 5. Review notes

Tell App Review:

- No account is required. The nickname field can be left blank.
- The app does not open web pages.
- Closing the window quits the app.
- Practice data is stored only on the device.

## Launcher note

Kids Computer can still launch the App Store build by bundle id. The sandbox does not block that. This app does not quit other apps and does not need the unsandboxed launcher entitlement.
