# FairyCraft App

Main Flutter client for FairyCraft.

Run:

```powershell
flutter pub get
flutter run -d chrome --dart-define=USE_MOCK_STORIES=true
```

To run with local backend TTS/STT, pass Story Agent URL via `dart-define`. Example (Android emulator / device pointing to localhost):

```powershell
flutter pub get
flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev --dart-define=STORY_AGENT_URL=http://10.0.2.2:8080/
```

Notes:
- Do NOT include the Voicemaker API key in the Flutter app. The backend must hold `VOICEMAKER_API_KEY`.
- On a local machine, `10.0.2.2` maps to the host loopback from Android emulator.
