# Voicemaker TTS/STT Integration Guide

## Overview

FairyCraft uses Voicemaker (https://developer.voicemaker.in) for text-to-speech (TTS) and speech-to-text (STT) functionality. The integration uses a **server-side proxy pattern** for security: the Flutter client never handles the Voicemaker API key directly.

## Architecture

```
┌──────────────────────────────┐
│       Flutter App            │
│  (fairycraft_app)            │
└─────────────────┬────────────┘
                  │
                  │ HTTP POST
                  │ TTS_PROXY_URL=/v1/tts/voicemaker
                  │
                  ▼
┌──────────────────────────────┐
│     Express.js Server        │
│    (story-agent)             │
│                              │
│ POST /v1/tts/voicemaker      │
│ POST /v1/tts/voicemaker/voices│
│ POST /v1/stt/voicemaker      │
│                              │
│ Has: VOICEMAKER_API_KEY      │
└─────────────────┬────────────┘
                  │
                  │ HTTPS POST
                  │ Authorization: Bearer <API_KEY>
                  │
                  ▼
┌──────────────────────────────┐
│    Voicemaker API            │
│  developer.voicemaker.in     │
│                              │
│ - /api/v1/voice/convert      │
│ - /api/v1/voice/list         │
│ - /api/v1/speech-to-text     │
└──────────────────────────────┘
```

## Setup Instructions

### 1. Server Configuration

#### Step 1a: Update Server Environment

Navigate to `server/story-agent/` and ensure `.env` contains:

```bash
VOICEMAKER_API_KEY=5991fea0-0a69-11f1-8770-c56efd80764d
```

Or set via environment variable:

```bash
# Linux/macOS
export VOICEMAKER_API_KEY=5991fea0-0a69-11f1-8770-c56efd80764d

# Windows PowerShell
$env:VOICEMAKER_API_KEY = "5991fea0-0a69-11f1-8770-c56efd80764d"
```

#### Step 1b: Start the Server

```bash
cd server/story-agent
npm install          # Install dependencies (first time only)
npm run dev          # Start development server
```

Server will be available at: `http://localhost:8080`

### 2. Flutter App Configuration

#### Step 2a: Run App with TTS Proxy URL

When launching the Flutter app, pass the proxy server URL as a dart-define:

```bash
cd apps/fairycraft_app

# For Android emulator (use 10.0.2.2 to reach host machine)
flutter run --dart-define=TTS_PROXY_URL=http://10.0.2.2:8080

# For iOS simulator (use localhost)
flutter run --flavor dev --dart-define=TTS_PROXY_URL=http://localhost:8080

# For physical device (use machine's local IP)
# First, find your machine IP:
#   - macOS: ipconfig getifaddr en0
#   - Linux: hostname -I
#   - Windows: ipconfig | grep -i "ipv4"
# Then:
flutter run --dart-define=TTS_PROXY_URL=http://<YOUR_IP>:8080
```

#### Step 2b: Verify Configuration

In the app, navigate to **Settings** → **Voice**. If properly configured:
- Voice selector dropdown shows available voices
- Selecting a voice and tapping "Test Voice" produces audio
- No "API key not configured" errors in logs

## API Endpoints

### TTS: Convert Text to Speech

**Endpoint**: `POST /v1/tts/voicemaker`

**Request**:
```json
{
  "text": "Hello, world!",
  "voiceId": "en-US-neural2-a",
  "speed": 1.0,
  "format": "mp3"
}
```

**Response** (Success):
- Status: `200`
- Content-Type: `audio/mpeg`
- Body: Binary audio data (MP3/WAV/OGG bytes)

**Response** (Error):
```json
{
  "ok": false,
  "error": "tts_unavailable",
  "safeMessage": "TTS service is not configured."
}
```

### TTS: List Available Voices

**Endpoint**: `POST /v1/tts/voicemaker/voices`

**Request**: `{}` (empty JSON body)

**Response** (Success):
```json
{
  "data": [
    {
      "id": "en-US-neural2-a",
      "name": "en-US-neural2-a",
      "language": "en-US",
      "gender": "FEMALE",
      "demo_url": "https://..."
    },
    {
      "id": "en-US-neural2-c",
      "name": "en-US-neural2-c",
      "language": "en-US",
      "gender": "MALE",
      "demo_url": "https://..."
    }
    // ... more voices
  ]
}
```

### STT: Convert Speech to Text

**Endpoint**: `POST /v1/stt/voicemaker`

**Request**: Multipart form-data
```
Content-Type: multipart/form-data
- audio: <binary WAV/MP3/OGG file>
- language: "en-US" (BCP-47 language code)
```

**Response** (Success):
```json
{
  "ok": true,
  "text": "Hello world",
  "confidence": 0.95
}
```

## Dart Client Usage

### Example: Fetch Available Voices

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> fetchVoices() async {
  final proxyUrl = String.fromEnvironment('TTS_PROXY_URL');
  if (proxyUrl.isEmpty) {
    throw Exception('TTS_PROXY_URL not configured');
  }

  final response = await http.post(
    Uri.parse('$proxyUrl/v1/tts/voicemaker/voices'),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch voices: ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final voices = data['data'] as List<dynamic>;
  return voices
      .map((v) => (v as Map<String, dynamic>)['id'] as String)
      .toList();
}
```

### Example: Convert Text to Speech

```dart
Future<Uint8List> convertTextToSpeech({
  required String text,
  required String voiceId,
  double speed = 1.0,
  String format = 'mp3',
}) async {
  final proxyUrl = String.fromEnvironment('TTS_PROXY_URL');
  if (proxyUrl.isEmpty) {
    throw Exception('TTS_PROXY_URL not configured');
  }

  final response = await http.post(
    Uri.parse('$proxyUrl/v1/tts/voicemaker'),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({
      'text': text,
      'voiceId': voiceId,
      'speed': speed,
      'format': format,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('TTS failed: ${response.statusCode}');
  }

  return response.bodyBytes; // Audio binary
}
```

## Security Considerations

### Best Practices

1. **Never Hardcode Keys**: Use environment variables or secure config files
2. **Rotate Keys Regularly**: Change the API key every 90 days
3. **Monitor Usage**: Track TTS/STT requests per user and IP
4. **Rate Limiting**: Server enforces per-IP and per-user limits
5. **HTTPS Only**: Always use HTTPS in production
6. **Backend Validation**: Server validates all requests before proxying

### API Key Scope

The Voicemaker API key (`5991fea0-0a69-11f1-8770-c56efd80764d`) is used for:
- TTS: Converting text/SSML to audio
- STT: Converting audio to text

It does NOT provide access to:
- User data or stored files
- Billing information
- API key management
- Admin console

### In Production

If deploying to production (e.g., Google Cloud Run, AWS Lambda):

1. **Use Secret Manager**: Store API key in Google Secret Manager or AWS Secrets Manager
2. **Rotate Before Deployment**: Never commit keys to git
3. **Audit Logs**: Enable request logging and audit trail
4. **Rate Limits**: Adjust `GLOBAL_RATE_LIMIT_PER_MIN` and `STT_RATE_LIMIT_PER_MIN` based on expected load
5. **SSL/TLS**: Use HTTPS with valid certificates

Example (Google Cloud Run):
```bash
gcloud run deploy story-agent \
  --set-env-vars VOICEMAKER_API_KEY=<KEY_FROM_SECRET_MANAGER> \
  --region=us-central1
```

## Troubleshooting

### Flutter App Can't Connect to Server

**Symptom**: "Connection failed" or timeout errors in app logs

**Solution**:
- For emulator: Use `http://10.0.2.2:8080` (not `localhost`)
- For simulator: Use `http://localhost:8080`
- For physical device: Use your machine's local IP (e.g., `http://192.168.1.100:8080`)
- Verify firewall allows port 8080

### "TTS service is not configured" Error

**Symptom**: App returns this error when fetching voices or converting text

**Solution**:
- Check `server/story-agent/.env` has `VOICEMAKER_API_KEY` set
- Restart server: `npm run dev`
- Verify API key is correct (check Voicemaker account)

### Voice List Empty

**Symptom**: Voice dropdown shows no voices

**Possible Causes**:
1. Network issue between app and server
2. Voicemaker API key is invalid or expired
3. Proxy server not running

**Solution**:
```bash
# Test the endpoint manually
curl -X POST http://localhost:8080/v1/tts/voicemaker/voices \
  -H "Content-Type: application/json" \
  -d '{}'

# Should return list of voices or error details
```

### Audio Playback Issues

**Symptom**: TTS audio is downloaded but doesn't play

**Possible Causes**:
1. Audio format mismatch (app expects MP3, server returns WAV)
2. Audio player not initialized
3. Audio bytes are corrupted

**Solution**:
- Ensure `format: "mp3"` is set in TTS request
- Verify audio player setup in app (`just_audio` package)
- Check server logs for any conversion errors

### Rate Limiting

**Symptom**: Requests return 429 "Too Many Requests"

**Solution**:
- Reduce request frequency in app
- Increase `GLOBAL_RATE_LIMIT_PER_MIN` in server `.env` (if load is expected)
- Implement client-side caching (cache voice list, cache TTS results)

## Performance Tips

### Client-Side

1. **Cache Voice List**: Fetch once and cache in local storage
2. **Batch Requests**: Don't convert multiple texts to speech simultaneously
3. **Lazy Load**: Only fetch voices when the voice selector is opened
4. **Reuse Audio**: Cache TTS results by text hash to avoid redundant conversions

### Server-Side

1. **Enable Caching**: Use Redis or Memcached for voice list cache
2. **Monitor Quota**: Track API requests per user to prevent quota exhaustion
3. **Optimize Audio Format**: Use MP3 with lower bitrate for faster transfer
4. **Connection Pooling**: Reuse HTTP connections to Voicemaker API

## Additional Resources

- **Voicemaker API Docs**: https://developer.voicemaker.in/docs
- **FairyCraft Flutter App**: `apps/fairycraft_app/README.md`
- **Story Agent Server**: `server/story-agent/README.md`
- **Architecture Overview**: `docs/architecture.md`

## Support

For issues or questions:
1. Check server logs: `npm run dev` output
2. Check Flutter logs: `flutter logs` or `logcat` (Android)
3. Test the API endpoint manually with `curl`
4. Review error response messages (they may indicate API key issues, network problems, etc.)
