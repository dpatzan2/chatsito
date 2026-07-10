import { randomUUID } from 'node:crypto';
import { createWriteStream } from 'node:fs';
import { stat, unlink } from 'node:fs/promises';
import { extname, join } from 'node:path';
import { pipeline } from 'node:stream/promises';
import multipart from '@fastify/multipart';
import type { FastifyInstance } from 'fastify';
import { AppError } from '../core/errors.js';

export const MAX_UPLOAD_BYTES = 25 * 1024 * 1024;

/** POST /uploads (autenticado): un archivo multipart → disco local. */
export async function uploadRoutes(app: FastifyInstance, dir: string): Promise<void> {
  await app.register(multipart, { limits: { files: 1, fileSize: MAX_UPLOAD_BYTES } });

  app.post('/uploads', async (req) => {
    const part = await req.file();
    if (!part) throw new AppError('VALIDATION', 'file field required');
    // extensión saneada del nombre original; el nombre en disco es un uuid
    const ext = extname(part.filename ?? '').toLowerCase().replace(/[^.a-z0-9]/g, '').slice(0, 9);
    const stored = `${randomUUID()}${ext}`;
    const path = join(dir, stored);
    await pipeline(part.file, createWriteStream(path));
    if (part.file.truncated) {
      await unlink(path).catch(() => {});
      throw new AppError('VALIDATION', 'file too large');
    }
    const { size } = await stat(path);
    return { url: `/uploads/${stored}`, name: part.filename ?? stored, size, mime: part.mimetype };
  });
}
