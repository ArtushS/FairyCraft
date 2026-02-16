import http from 'node:http';

import { createApp } from './app';
import { loadConfig } from './config';

const config = loadConfig();
const { app, attachVoicemakerTtsStreamProxy } = createApp({ config });
const server = http.createServer(app);
attachVoicemakerTtsStreamProxy(server);

server.listen(config.port, () => {
  // eslint-disable-next-line no-console
  console.log(`FairyCraft story-agent listening on :${config.port}`);
});
