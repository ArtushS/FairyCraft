# Architecture

## High-level flow

```text
fairycraft_app
  -> story-agent (Cloud Run)
    -> policy check (admin_policy/runtime)
    -> AI engine (MOCK or Vertex)
    -> optional storage (illustrations)
  -> response to fairycraft_app
```

Admin flow:

```text
fairycraft_admin
  -> Firebase Auth
  -> admin_policy/runtime (read/write)
  -> usage_daily (read)
```

## Story-agent endpoints

- `GET /healthz` -> `{ ok: true }`
- `POST /` -> routes by `action`
- `POST /v1/story/create`
- `POST /v1/story/continue`
- `POST /v1/story/illustrate`

`/v1/story/illustrate` never returns `501`; if disabled/unavailable it returns `200` with placeholder image payload.

## Request/response contract

Request fields (JSON):

- `requestId?`
- `action`: `generate | continue | illustrate`
- `storyLang`: `ru | en | hy`
- `ageGroup?`: `3_5 | 6_8 | 9_12`
- `storyLength?`: `short | medium | long`
- `creativityLevel?`: `0..1`
- `selection?`: `{ hero?, location?, storyType?, idea? }`
- `storyId?`, `choice?`, `prompt?`, `image?`

Response fields (JSON):

- `requestId`, `ok`
- `error?`, `safeMessage?`
- `storyId?`, `title?`
- `chapter?`, `chapters?`
- `image?`
- `debug?` (dev only)

## Runtime policy document

Path: `admin_policy/runtime`

Schema fields:

- `enable_story_generation` (bool)
- `enable_illustrations` (bool)
- `model_allowlist` (string[])
- `max_output_tokens` (int)
- `temperature` (number)
- `max_input_chars` (int)
- `max_output_chars` (int)
- `daily_story_limit` (int)
- `ip_rate_per_min` (int)
- `uid_rate_per_min` (int)
- `max_body_kb` (int)
- `request_timeout_ms` (int)

Policy is cached for 60 seconds. If policy read/validation fails (fail-closed):

- generation endpoints return `503` (disabled)
- illustrate returns `200` placeholder

## Security and quality controls

- Optional Firebase ID token auth: `AUTH_REQUIRED=true|false`
- Optional Firebase App Check: `APPCHECK_REQUIRED=true|false`
- Audit records use server-generated `auditId` (`story_audit/{auditId}`), never client `requestId` as document id.
- In-memory per-IP/per-UID limiter has TTL, cap, and pruning to avoid memory DoS.
- Dev metadata is gated: debug metadata is omitted when `NODE_ENV=production`.
- `STORE_DISABLED=true` enables local in-memory mode for server sessions/audit/usage.

## Storage model

Collections used by server:

- `stories/{storyId}`
- `story_audit/{auditId}`
- `usage_daily/{uid_yyyymmdd}`
- `admin_policy/runtime`

## Android signing ownership

Android release signing is a client build responsibility (`apps/fairycraft_app`) and is not solved by server code.
