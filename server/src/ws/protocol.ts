import { z } from 'zod';

export const ClientFrame = z.object({
  v: z.literal(1),
  op: z.string(),
  seq: z.number().int().nonnegative(),
  d: z.unknown().optional(),
});

const CONTENT: Record<string, z.ZodType> = {
  text: z.object({ text: z.string().min(1).max(4000) }),
  image: z.looseObject({}),
  video: z.looseObject({}),
  doc: z.looseObject({ name: z.string(), size: z.string() }),
  sticker: z.object({ sticker: z.string().min(1) }),
};

export const MsgSendInput = z.object({
  conversationId: z.uuid().optional(),
  channelId: z.uuid().optional(),
  type: z.enum(['text', 'image', 'video', 'doc', 'sticker']),
  content: z.record(z.string(), z.unknown()),
}).superRefine((val, ctx) => {
  if (!val.conversationId === !val.channelId) {
    ctx.addIssue({ code: 'custom', message: 'exactly one of conversationId or channelId' });
  }
  if (!CONTENT[val.type].safeParse(val.content).success) {
    ctx.addIssue({ code: 'custom', message: `invalid content for type ${val.type}` });
  }
});

export const serverFrame = (op: string, d: unknown): string =>
  JSON.stringify({ v: 1, op, ts: Date.now(), d });
