import WebSocket from 'ws';

export interface WsFrame { v: 1; op: string; ts?: number; d?: Record<string, unknown> }

export function wsClient(url: string) {
  const ws = new WebSocket(url);
  const queue: WsFrame[] = [];
  const waiters: Array<(f: WsFrame) => void> = [];
  ws.on('message', (raw) => {
    const frame = JSON.parse(String(raw)) as WsFrame;
    const w = waiters.shift();
    if (w) w(frame); else queue.push(frame);
  });
  return {
    ws,
    open: new Promise<void>((res, rej) => { ws.on('open', () => res()); ws.on('error', rej); }),
    closed: new Promise<number>((res) => ws.on('close', (code) => res(code))),
    next(timeoutMs = 5000): Promise<WsFrame> {
      const q = queue.shift();
      if (q) return Promise.resolve(q);
      return new Promise((res, rej) => {
        const t = setTimeout(() => rej(new Error('ws timeout waiting for frame')), timeoutMs);
        waiters.push((f) => { clearTimeout(t); res(f); });
      });
    },
    send(op: string, seq: number, d?: unknown) { ws.send(JSON.stringify({ v: 1, op, seq, d })); },
    close() { ws.close(); },
  };
}
