import type { IncomingMessage, Server as HttpServer } from 'node:http';

import { WebSocket, WebSocketServer } from 'ws';

import {
  PerUserConcurrencyLimiter,
  VOICEMAKER_TTS_STREAM_URL,
  VoicemakerHttpError,
  VoicemakerService,
} from '../services/voicemaker';

interface AttachTtsStreamProxyOptions {
  server: HttpServer;
  path?: string;
  voicemakerService: VoicemakerService;
  limiter: PerUserConcurrencyLimiter;
  resolveUserKey: (request: IncomingMessage) => string;
  onError?: (message: string, error?: unknown) => void;
}

export const attachTtsStreamProxy = ({
  server,
  path = '/v1/tts/stream',
  voicemakerService,
  limiter,
  resolveUserKey,
  onError,
}: AttachTtsStreamProxyOptions): void => {
  const wss = new WebSocketServer({ noServer: true });

  server.on('upgrade', (request, socket, head) => {
    if (!isPathMatch(request.url, path)) {
      socket.write('HTTP/1.1 404 Not Found\r\nConnection: close\r\n\r\n');
      socket.destroy();
      return;
    }

    try {
      voicemakerService.getApiKey();
    } catch (error) {
      socket.write('HTTP/1.1 503 Service Unavailable\r\nConnection: close\r\n\r\n');
      socket.destroy();
      onError?.('voicemaker key missing for websocket stream', error);
      return;
    }

    wss.handleUpgrade(request, socket, head, (clientSocket) => {
      wss.emit('connection', clientSocket, request);
    });
  });

  wss.on('connection', (clientSocket, request) => {
    const userKey = resolveUserKey(request);
    if (!limiter.tryAcquire(userKey)) {
      clientSocket.send(JSON.stringify({ ok: false, error: 'tts_parallel_limit_reached' }));
      clientSocket.close(1013, 'parallel limit');
      return;
    }

    let released = false;
    let closed = false;
    let upstreamOpen = false;
    let ttsPayloadText: string | null = null;
    let hasReceivedClientPayload = false;
    let upstream: WebSocket | null = null;

    const releaseLimiter = () => {
      if (released) {
        return;
      }
      released = true;
      limiter.release(userKey);
    };

    let idleTimer = setTimeout(() => {
      closeWithError('stream_timeout', 'Streaming timed out after 60 seconds of inactivity.');
    }, 60_000);

    const touchIdleTimeout = () => {
      clearTimeout(idleTimer);
      idleTimer = setTimeout(() => {
        closeWithError('stream_timeout', 'Streaming timed out after 60 seconds of inactivity.');
      }, 60_000);
    };

    const safeClose = () => {
      if (closed) {
        return;
      }
      closed = true;
      clearTimeout(idleTimer);
      releaseLimiter();

      if (upstream && (upstream.readyState === WebSocket.OPEN || upstream.readyState === WebSocket.CONNECTING)) {
        upstream.close();
      }

      if (clientSocket.readyState === WebSocket.OPEN || clientSocket.readyState === WebSocket.CONNECTING) {
        clientSocket.close();
      }
    };

    const closeWithError = (errorCode: string, reason: string) => {
      if (clientSocket.readyState === WebSocket.OPEN) {
        clientSocket.send(
          JSON.stringify({
            ok: false,
            error: errorCode,
            safeMessage: reason,
          }),
        );
      }
      safeClose();
    };

    const upstreamSocket = new WebSocket(VOICEMAKER_TTS_STREAM_URL, {
      headers: {
        Authorization: `Bearer ${voicemakerService.getApiKey()}`,
      },
      handshakeTimeout: 30_000,
    });
    upstream = upstreamSocket;

    const trySendPayloadToUpstream = () => {
      if (!upstreamOpen || ttsPayloadText == null) {
        return;
      }
      if (!upstream || upstream.readyState !== WebSocket.OPEN) {
        return;
      }
      upstream.send(ttsPayloadText);
      ttsPayloadText = null;
      touchIdleTimeout();
    };

    upstreamSocket.on('open', () => {
      upstreamOpen = true;
      touchIdleTimeout();
      trySendPayloadToUpstream();
    });

    upstreamSocket.on('message', (chunk, isBinary) => {
      touchIdleTimeout();
      if (clientSocket.readyState !== WebSocket.OPEN) {
        return;
      }
      clientSocket.send(chunk, { binary: isBinary });
    });

    upstreamSocket.on('error', (error) => {
      onError?.('upstream websocket error', error);
      closeWithError('tts_stream_upstream_failed', 'Streaming provider is temporarily unavailable.');
    });

    upstreamSocket.on('close', () => {
      safeClose();
    });

    clientSocket.on('message', (raw, isBinary) => {
      touchIdleTimeout();

      if (hasReceivedClientPayload) {
        return;
      }
      hasReceivedClientPayload = true;

      const text = isBinary ? raw.toString() : String(raw);
      try {
        const decoded = JSON.parse(text) as unknown;
        const normalized = voicemakerService.normalizeTtsRequest(decoded);
        const upstreamPayload = voicemakerService.buildUpstreamTtsPayload(normalized);
        ttsPayloadText = JSON.stringify(upstreamPayload);
        trySendPayloadToUpstream();
      } catch (error) {
        if (error instanceof VoicemakerHttpError) {
          closeWithError(error.errorCode, error.safeMessage);
          return;
        }
        closeWithError('invalid_tts_request', 'Invalid websocket payload for TTS stream.');
      }
    });

    clientSocket.on('close', () => {
      safeClose();
    });

    clientSocket.on('error', (error) => {
      onError?.('client websocket error', error);
      safeClose();
    });
  });
};

const isPathMatch = (requestUrl: string | undefined, targetPath: string): boolean => {
  if (!requestUrl) {
    return false;
  }

  const parsed = new URL(requestUrl, 'http://localhost');
  return normalizePath(parsed.pathname) === normalizePath(targetPath);
};

const normalizePath = (value: string): string => {
  if (value.endsWith('/') && value.length > 1) {
    return value.slice(0, -1);
  }
  return value;
};
