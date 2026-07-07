import type { FastifyInstance } from 'fastify';
import { DEV_LIVEKIT, verifyWebhook } from '../voice/livekit.js';
import { channelRecipients } from '../community/channel-messages.js';
import type { VoiceStates } from '../voice/state.js';
import type { Hub } from '../ws/hub.js';
import type { Deps } from '../app.js';

export function voiceWebhookRoutes(
  app: FastifyInstance, deps: Deps, hub: Hub, voice: VoiceStates,
): void {
  // LiveKit manda content-type application/webhook+json; guardamos el body crudo
  // porque la firma incluye el sha256 del texto exacto
  app.addContentTypeParser('application/webhook+json', { parseAs: 'string' },
    (_req, body, done) => done(null, body));

  app.post('/livekit/webhook', async (req, reply) => {
    const lk = deps.lk ?? DEV_LIVEKIT;
    const ev = await verifyWebhook(lk, String(req.body), req.headers.authorization ?? '');
    const channelId = ev.room?.name;
    if (!channelId) return reply.status(200).send();

    if (ev.event === 'participant_joined' && ev.participant) {
      voice.join(channelId, ev.participant.identity);
    } else if (ev.event === 'participant_left' && ev.participant) {
      voice.leave(channelId, ev.participant.identity);
    } else if (ev.event === 'room_finished') {
      voice.clear(channelId);
    } else {
      return reply.status(200).send();
    }

    const userIds = await channelRecipients(deps.db, channelId)
      .then((r) => r.userIds)
      .catch(() => [] as string[]); // canal ya borrado: solo limpiar estado
    hub.sendTo(userIds, 'voice.state', { channelId, members: voice.members(channelId) });
    return reply.status(200).send();
  });
}
