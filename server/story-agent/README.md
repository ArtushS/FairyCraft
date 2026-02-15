# Story Agent Server

Node.js/Express backend service for the FairyCraft app. Provides story generation, text-to-speech (TTS), and speech-to-text (STT) proxy endpoints.

## Features

- **Story Generation**: Uses Google Vertex AI / Gemini to generate interactive stories
- **TTS Proxy**: Secure server-side proxy for Voicemaker text-to-speech service
- **STT Proxy**: Secure server-side proxy for Voicemaker speech-to-text service
- **Policy Management**: Fine-grained control over story generation and content
- **Rate Limiting**: Per-IP and per-user-ID rate limits to prevent abuse
- **Caching**: Optional Firestore-based story caching

## Setup

### Prerequisites
- Node.js 18+
- npm or yarn

### Installation

```bash
cd server/story-agent
npm install
```

### Configuration

Copy `.env.example` to `.env` and fill in required values:

```bash
cp .env.example .env
```

Key environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8080` |
| `NODE_ENV` | Environment (`development`, `production`) | `development` |
| `VOICEMAKER_API_KEY` | Voicemaker service API key | (required for TTS/STT) |
| `GOOGLE_CLOUD_PROJECT` | GCP project ID (for Vertex AI) | (optional) |
| `GEMINI_MODEL` | Gemini model name | `gemini-2.0-flash` |
| `AUTH_REQUIRED` | Require Bearer token auth | `false` |
| `MOCK_ENGINE` | Use mock story engine (no GCP) | `true` |

## Development

### Build

```bash
npm run build
```

### Run (Development)

```bash
npm run dev
```

Starts server on `http://localhost:8080`

### Run (Production)

```bash
npm run build
npm start
```

### Tests

```bash
npm test
```

## API Endpoints

### Story Generation

**POST `/v1/story`**

Generate a new interactive story.

```typescript
Request body:
{
  "title": string;           // Story title
  "genre": string;           // Genre (fairy_tale, adventure, etc.)
  "characterName": string;   // Main character name
  "language": string;        // BCP-47 language code (e.g., "en", "es")
}

Response:
{
  "ok": boolean;
  "storyId": string;
  "content": string;
  "image": {
    "disabled": boolean;
    "prompt": string;
    "url": string;
  };
  "debug": {...};            // Only in dev mode
}
```

### Text-to-Speech (TTS)

**POST `/v1/tts/voicemaker`**

Convert text to speech using Voicemaker backend.

```typescript
Request body: Voicemaker TTS API payload
{
  "text": string;           // Text to convert
  "voiceId": string;        // Voice ID from /v1/tts/voicemaker/voices
  "speed": number;          // Speed (0.5–2.0)
  "format": string;         // Format (mp3, wav, ogg)
}

Response: Audio binary (mp3/wav/ogg) or JSON error
Content-Type: audio/mpeg (or appropriate audio type)
```

**POST `/v1/tts/voicemaker/voices`**

List available voices from Voicemaker.

```typescript
Request body: {} (empty)

Response:
{
  voices: Array<{
    id: string;
    name: string;
    language: string;
    gender: string;
    demo_url: string;
  }>
}
```

### Speech-to-Text (STT)

**POST `/v1/stt/voicemaker`**

Convert speech audio to text using Voicemaker backend. Requires multipart form upload.

```bash
Request: multipart/form-data
- audio: binary audio file (wav, mp3, ogg)
- language: string (BCP-47 code)

Response:
{
  "ok": boolean;
  "text": string;           // Transcribed text
  "confidence": number;     // 0–1 confidence score
}
```

## Integration with Flutter Client

### TTS Proxy Flow

```
Flutter Client
    ↓
    └→ POST http://10.0.2.2:8080/v1/tts/voicemaker (with text, voiceId)
       (Server has VOICEMAKER_API_KEY)
       └→ Forwards to Voicemaker API (https://developer.voicemaker.in/api/v1/voice/convert)
       └→ Returns audio bytes to client
```

**Why This Design?**

1. **Security**: API key is never exposed to the client
2. **Flexibility**: Can swap TTS providers server-side without client changes
3. **Rate Limiting**: Server enforces quotas per user/IP
4. **Monitoring**: Server logs all TTS requests for analytics

### Flutter Client Setup

In your Flutter app, when using the TTS proxy:

```dart
// Run with:
flutter run --dart-define=TTS_PROXY_URL=http://10.0.2.2:8080

// Call the proxy endpoint:
final response = await http.post(
  Uri.parse('$TTS_PROXY_URL/v1/tts/voicemaker'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({
    'text': 'Hello, world!',
    'voiceId': 'en-US-neural2-a',
    'speed': 1.0,
    'format': 'mp3',
  }),
);

if (response.statusCode == 200) {
  // response.bodyBytes contains audio data
  await audioPlayer.setAudioSource(
    BytesAudioSource(response.bodyBytes),
  );
}
```

## Voicemaker Service Details

**Service**: Voicemaker (https://developer.voicemaker.in)

**Endpoints Proxied**:
- `https://developer.voicemaker.in/api/v1/voice/convert` (TTS)
- `https://developer.voicemaker.in/api/v1/voice/list` (Voice list)
- `https://developer.voicemaker.in/api/v1/speech-to-text` (STT)

**Authentication**: Bearer token in `Authorization` header

**Current API Key**: `5991fea0-0a69-11f1-8770-c56efd80764d`

⚠️ **SECURITY WARNING**: This key is for development only. In production:
- Use a secure secrets manager (Google Secret Manager, AWS Secrets Manager, etc.)
- Rotate keys regularly
- Monitor API usage
- Never commit keys to version control

## Docker

Build and run via Docker:

```bash
docker build -t fairycraft-story-agent .
docker run -e VOICEMAKER_API_KEY=... -p 8080:8080 fairycraft-story-agent
```

## Error Handling

The server returns consistent error responses:

```json
{
  "ok": false,
  "error": "error_code",
  "safeMessage": "User-friendly error message"
}
```

Common error codes:
- `request_timeout` — Request exceeded timeout
- `unauthorized` — Missing or invalid auth token
- `rate_limited` — Rate limit exceeded
- `tts_unavailable` — TTS service not configured
- `tts_upstream_failed` — Voicemaker API error
- `invalid_request` — Malformed request body

## Troubleshooting

### TTS proxy returns 503 "TTS service not configured"
- Check `.env` file has `VOICEMAKER_API_KEY` set
- Ensure `NODE_ENV` is set correctly
- Verify Voicemaker API key is valid

### Flutter client can't reach emulator host
- Use `http://10.0.2.2:8080` (not `localhost`) for Android emulator
- Use `http://localhost:8080` for iOS simulator or real device (if on same network)

### Rate limits being hit
- Adjust `GLOBAL_RATE_LIMIT_PER_MIN`, `STT_RATE_LIMIT_PER_MIN` in `.env`
- In production, consider using Redis for distributed rate limiting

## Performance Optimizations

- **Streaming**: Large responses (audio files) are streamed to clients
- **Caching**: Story results are cached in Firestore (optional)
- **Rate Limiting**: Prevents resource exhaustion from abusive clients
- **Timeouts**: All external requests have configurable timeouts (`REQUEST_TIMEOUT_MS`)

## License

Part of the FairyCraft project. See [LICENSE](../../LICENSE) for details.
