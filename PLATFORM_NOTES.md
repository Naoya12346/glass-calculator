# Platform setup

Generate the native runners once (they are intentionally not hand-written here):

```bash
flutter create --platforms=android,ios,web .
```

## Android

- Minimum SDK: `flutter.minSdkVersion` (21+) is sufficient.
- `android/app/src/main/AndroidManifest.xml`:
  - Keep the standard `android.permission.INTERNET` entry if you want Google Fonts to download on first launch. The app falls back to system fonts offline.
  - `share_plus` handles its own `queries` entries; if your target restricts intents, add the standard `ACTION_SEND` queries block from the `share_plus` README.
- App icon: replace the mipmap assets under `android/app/src/main/res/mipmap-*/ic_launcher.png` (or run `flutter launcher-icons`).
- Splash: update `android/app/src/main/res/drawable/launch_background.xml` with the gradient from `lib/core/constants/app_colors.dart`.
- Edge-to-edge: enabled in `lib/main.dart` via `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`.

## iOS

- Set the deployment target in `ios/Podfile` to at least `13.0`.
- `ios/Runner/Info.plist` needs no extra permissions. Clipboard, haptics and share sheet require no entitlement.
- App icon: replace `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
- Splash: update `ios/Runner/Assets.xcassets/LaunchImage.imageset` / `LaunchScreen.storyboard` with the same gradient.
- Run `cd ios && pod install --repo-update` before the first iOS build on macOS.

## Web / desktop

- No extra setup. Hover, focus and mouse cursor effects are implemented with `MouseRegion`.

## Run and build

```bash
flutter pub get
flutter analyze
flutter test
flutter run

flutter build apk --release
flutter build appbundle --release
flutter build ios --release
flutter build web --release
```

## Notes

- Currency rates in `lib/features/converter/data/converter_catalog.dart` are offline demo rates, not live market data.
- The sound preference is persisted in settings; haptics are fully implemented. Add a bundled click asset and an audio plugin when audible feedback is desired.
