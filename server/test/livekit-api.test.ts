import { beforeAll, afterAll, it, expect } from 'vitest';
import { GenericContainer, type StartedTestContainer } from 'testcontainers';
import { roomApi, type LiveKitCfg } from '../src/voice/livekit.js';

let container: StartedTestContainer;
let cfg: LiveKitCfg;

beforeAll(async () => {
  container = await new GenericContainer('livekit/livekit-server:latest')
    .withCommand(['--dev', '--bind', '0.0.0.0'])
    .withExposedPorts(7880)
    .start();
  cfg = {
    url: `ws://${container.getHost()}:${container.getMappedPort(7880)}`,
    apiKey: 'devkey', apiSecret: 'secret',
  };
});
afterAll(async () => { await container.stop(); });

it('a valid admin token reaches the API (404 for a nonexistent room, not 401)', async () => {
  await expect(roomApi(cfg).updateParticipant('no-room', 'nobody', false))
    .rejects.toThrow(/404|not found/i);
});

it('a token signed with the wrong secret is rejected with 401', async () => {
  const bad = roomApi({ ...cfg, apiSecret: 'wrong-secret-wrong-secret' });
  await expect(bad.removeParticipant('no-room', 'nobody')).rejects.toThrow(/401/);
});
