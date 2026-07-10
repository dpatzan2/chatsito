import type { WebSocket } from 'ws';
import { serverFrame } from './protocol.js';

/** userId → sockets vivos. Fan-out en memoria: un solo nodo. */
export class Hub {
  private sockets = new Map<string, Set<WebSocket>>();

  add(userId: string, ws: WebSocket): void {
    let set = this.sockets.get(userId);
    if (!set) this.sockets.set(userId, (set = new Set()));
    set.add(ws);
  }

  isOnline(userId: string): boolean {
    return this.sockets.has(userId);
  }

  remove(userId: string, ws: WebSocket): void {
    const set = this.sockets.get(userId);
    set?.delete(ws);
    if (set?.size === 0) this.sockets.delete(userId);
  }

  closeAll(userId: string): void {
    for (const ws of this.sockets.get(userId) ?? []) ws.close(4000, 'account deleted');
  }

  sendTo(userIds: string[], op: string, d: unknown): void {
    const frame = serverFrame(op, d);
    for (const id of new Set(userIds)) {
      for (const ws of this.sockets.get(id) ?? []) ws.send(frame);
    }
  }
}
