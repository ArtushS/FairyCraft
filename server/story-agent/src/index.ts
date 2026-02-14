import { createApp } from './app';
import { loadConfig } from './config';

const config = loadConfig();
const { app } = createApp({ config });

app.listen(config.port, () => {
  // eslint-disable-next-line no-console
  console.log(`FairyCraft story-agent listening on :${config.port}`);
});
