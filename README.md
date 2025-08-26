## Sorosokay — Yoruba Speech-to-Text Notes

Turn your voice into notes, fast. Sorosokay is a Flutter app that lets you dictate notes and manage them in-app. It is designed for speech-first note taking, with an emphasis on Yoruba language support.

Note: current implementation uses `speech_to_text` with `en_US`. Yoruba locale support can be enabled with a supported `localeId` if available on device.

### Demo

<!-- Add your GIF/video demo links or images here -->
<!-- Example: -->

![Voice to note flow](docs/videos/tts_demo.gif)

![Voice to note flow](docs/videos/theme_demo.gif)

![Voice to note flow](docs/videos/create_note_demo.gif)

<!-- ![Notes list screen](docs/screens/notes_list.png) -->

<!-- ### Screenshots -->

<!-- Replace placeholders with your actual images -->
<!-- ![Home - Voice](docs/screens/home_voice.png) -->
<!-- ![Notes - List](docs/screens/notes_list.png) -->
<!-- ![Settings](docs/screens/settings.png) -->

---

### Features

- Voice dictation to text using `speech_to_text`
- Create a note from a recording with one tap
- Live transcript preview with pause/resume/stop controls
- Notes list view with newest-first ordering
- Light/dark theming via provider-based `ThemeProvider`
- Toast feedback on save

Planned:

- Yoruba (`yo_NG`) locale selection when supported on device
- Persist notes and settings (uses providers; persistence can be extended)
- Export/share notes

---

### Tech Stack

- Flutter (Dart)
- State management: `provider`
- Speech recognition: `speech_to_text`
- UI/UX: Material 3 styling, simple voice visualization
- Utilities: `shared_preferences`, `fluttertoast`, `timeago`, `intl`, `permission_handler`, `liquid_pull_to_refresh`

---

### Project Structure

```
lib/
  main.dart                 # App entry, theme + providers
  models/note.dart          # Note model
  providers/                # Notes & theme providers
  screens/
    home_page.dart          # Tab scaffold (Voice, Notes, Settings)
    voice_screen.dart       # Dictation & controls
    content_screen.dart     # Notes list
    settings_screen.dart    # Theme/settings
  services/speech_service.dart  # Speech-to-text wrapper
  widgets/voice_animation.dart  # Simple listening animation
assets/images/              # Bottom nav icons
```

---

### Getting Started

Prerequisites:

- Flutter SDK installed and configured
- iOS/macOS: Xcode + CocoaPods; Android: Android Studio + SDK

Install dependencies:

```bash
flutter pub get
```

Run on a device/emulator:

```bash
flutter run
```

Build release:

```bash
flutter build apk    # Android
flutter build ios    # iOS (requires signing)
```

---

### Permissions

This app requests microphone access to perform speech recognition.

- Android: configured via `AndroidManifest.xml`
- iOS: ensure `NSMicrophoneUsageDescription` and speech recognition usage strings exist in `Info.plist`

---

### Localization and Yoruba Support

`speech_to_text` recognition depends on device support for locales. To target Yoruba, set `localeId` (e.g., `yo_NG`) in `SpeechService.startListening` once available and supported on the device.

```dart
await _speechToText.listen(
  onResult: ...,
  localeId: 'yo_NG', // switch from 'en_US' when supported
);
```

---

### Contributing

Issues and pull requests are welcome. If you plan a larger change, please open an issue first to discuss what you’d like to change.

---

### License

MIT License. See `LICENSE` (add one if missing).

---

### Acknowledgements

- Flutter team and community
- `speech_to_text` and `provider` maintainers

---

### Badges (optional)

<!-- Add badges as desired -->
<!-- [![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)]() -->
<!-- [![Platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20|%20desktop-lightgrey)]() -->
