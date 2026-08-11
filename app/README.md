# AnaCoo Tailor — appointment book

An offline-first internal app for AnaCoo Tailor (R&F Princess Cove Block A7-1,
Johor Bahru). There is no customer-facing side: customers request appointments
over WhatsApp on [anacoo.live](https://anacoo.live), and this app turns those
messages into scheduled work and reminds the tailor before each one.

No backend, no login, no network required for anything the app does.

## How work moves (v2)

Pipeline is five steps: **Booked → Received → Sewing → Ready → Collected**.

Received is the garment being handed over, which happens on its own day and is
worth knowing about separately from the work having started. Reaching it marks
the drop-off appointment done.

The last step is `JobStatus.done` in code — the enum is persisted by name, so it
keeps the name it was stored under while the UI calls it what it is.

- **Paste** a complete WhatsApp request (name + phone + date + time) and the
  job is saved immediately — no editor, no detail screen. Incomplete requests
  still open a short form.
- Collection is optional: add it later from the job editor (Suggested uses the
  turnaround setting). It is never created automatically.
- Today tiles have a **Next** button that advances the job one step. Collected
  closes any open appointments.
- Paste, New, Filter and Sort are pinned in a bar below the Today list, where
  the hand already is and where a long list cannot scroll them out of reach.
- WhatsApp **Ready** jumps the job to Ready; Confirm only messages the customer.
- Swipe a name left in Customers to archive it. Archiving only hides the name —
  the jobs and appointments carry on, because the shop still has the clothes.
  The snackbar offers Undo, and the archive itself is one tap away in the app
  bar, where a swipe puts the name back.

Launcher icons are generated from `assets/branding/app_icon.png` (AnaCoo mark
on black). Regenerate with `dart run flutter_launcher_icons`.

## The shape of the problem

Every job has a drop-off appointment, and may also have a collection. Collection
is optional and set by the tailor when needed. The app warns about clashes and
closed days, and reminds ahead of each appointment.

## Stack

Flutter (Dart 3, Material 3, light + dark), Riverpod, Drift over SQLite,
`flutter_local_notifications` with `timezone`. Targets Android 8+ and iOS 15+.
UI in English, 中文, Bahasa Melayu and Tiếng Việt.

Vietnamese is app-only: the website offers the first three, so a pasted request
never arrives in Vietnamese, but the parser reads Vietnamese labels, `tháng`
dates and `8h tối` times for a request typed by hand.

## Layout

```
lib/
  data/          Drift schema, DAOs, the job repository
  domain/        Pure Dart: parser, scheduling rules, reminder rules, shop time
  services/      Notifications, clipboard/share intake, backup, wa.me links
  providers/     Riverpod wiring
  ui/            Today, Calendar, Job editor/detail, Customers, Settings
  l10n/          UI copy in the four languages
```

Everything in `domain/` is free of Flutter and Drift imports, which is why the
parser and the notification planner can be tested directly.

## Running it

```sh
flutter pub get
dart run build_runner build      # Drift codegen — needed after schema changes
flutter run
```

## Tests

```sh
flutter analyze
flutter test                     # 154 tests, no device needed
```

`test/parser_test.dart` covers the six cases the spec calls out (the exact
sample message, the same message stripped of `*`, the three time formats,
day-first `6/8/2026`, multi-line notes with emoji, and garbage returning null)
plus the Malay, Chinese and Vietnamese label sets.

`test/localisation_test.dart` walks `AppStrings.supportedLocales` over every
label table. The tables are plain maps, so a language missing from one of them
falls back to English silently rather than failing to compile — this is what
catches that.

`test/notification_scheduler_test.dart` proves the zero-orphan guarantee:
schedule → reschedule → cancel leaves nothing pending, and the OS's pending set
always equals the app's own ledger.

There is a device-level version of the same guarantee against the real
notification centre:

```sh
flutter test integration_test/notifications_test.dart   # needs a device
```

## How reminders stay honest

The app keeps its own ledger of what it has asked the OS to show
(`pending_notifications`), where the row id *is* the platform notification id.
`planNotifications` is a pure function that returns the set of notifications
that *should* exist right now; `NotificationScheduler.rebuild()` diffs that plan
against the ledger by a stable dedupe key, cancels what the plan dropped, and
arms what is new. Every mutation — save, status change, delete, settings edit —
ends in a rebuild, so there is no path that moves an appointment without its
reminders following.

Appointments are stored as UTC instants and always read back through
`Asia/Kuala_Lumpur`, and everything is scheduled with `TZDateTime` rather than
raw `Duration` offsets, so a device clock or timezone change cannot drift them.

Two platform limits are handled explicitly rather than hoped away:

- **iOS caps an app at 64 pending notifications.** Only the earliest slice is
  registered; the rest stay in the ledger and are topped up on every app open
  and resume.
- **Android 12+ may deny `SCHEDULE_EXACT_ALARM`.** The app falls back to
  inexact alarms and says so plainly in Settings, with a button to grant exact
  alarms. Settings also carries a one-time explainer about Doze and OEM battery
  optimisation — Xiaomi, Oppo, Vivo and Huawei kill background alarms hard, and
  this matters in the Malaysian market.

## Platform setup

### Android

Everything is wired in `android/app/src/main/AndroidManifest.xml` and
`build.gradle.kts` already: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`,
`RECEIVE_BOOT_COMPLETED` with the boot receiver that restores alarms, the
`ACTION_SEND` share target, `minSdk 26`, and core library desugaring.

Nothing manual to do — `flutter build apk` should work as is.

### iOS share extension (one-time Xcode setup)

The Swift source, `Info.plist`, storyboard and entitlements for the share
extension are committed under `ios/Share Extension/`, but the Xcode *target*
that builds them has to be created by hand once — a target cannot be added to
`project.pbxproj` reliably from outside Xcode.

1. `flutter config --enable-swift-package-manager` (the plugin is SPM-only).
2. Xcode → File → New → Target → **Share Extension**, name it
   `Share Extension`. Set its deployment target to **iOS 15**, matching Runner.
3. Replace the generated `ShareViewController.swift`, `Info.plist` and
   `MainInterface.storyboard` with the committed ones in `ios/Share Extension/`.
4. On **both** Runner and Share Extension: Signing & Capabilities → **App
   Groups** → add `group.com.anacoo.anacooTailor`.
5. On **both** targets: Build Settings → **+** → add a user-defined setting
   `CUSTOM_GROUP_ID` = `group.com.anacoo.anacooTailor`.
6. Share Extension → General → Frameworks and Libraries → **+** → add the
   `receive-sharing-intent` library from the `receive_sharing_intent` package.
7. Runner → Build Phases → drag **Embed Foundation Extension** above
   **Thin Binary**.

Runner's `Info.plist` already declares `AppGroupId`, the
`ShareMedia-$(PRODUCT_BUNDLE_IDENTIFIER)` URL scheme, and the usage strings.

The other two intake routes — the "Paste appointment" button and the on-resume
clipboard banner — need no native setup and work on both platforms today.

## Not verified in CI

`flutter analyze` and the full test suite run clean, but **no APK or IPA has
been built from this tree**: the container this was developed in cannot reach
`dl.google.com`, so the Android SDK is unavailable, and iOS needs macOS. The
first `flutter build apk` on a real machine is the outstanding check — in
particular the Gradle plugin resolution and `package:sqlite3`'s native-asset
hook, neither of which the analyzer exercises.

## Backup

Manual JSON export and import through the system share sheet, plus a CSV of
jobs. Import replaces the whole database and asks first; it also clears the OS's
pending notifications before restoring, because the imported rows carry new ids.

There is deliberately no cloud sync, no account, and no analytics.
