import { describe, it, expect } from 'vitest';
import { VoiceStates } from '../src/voice/state.js';

describe('VoiceStates', () => {
  it('join/leave tracks members per channel; join is idempotent', () => {
    const v = new VoiceStates();
    v.join('c1', 'u1');
    v.join('c1', 'u1');
    v.join('c1', 'u2');
    v.join('c2', 'u3');
    expect(v.members('c1')).toEqual([
      { userId: 'u1', muted: false }, { userId: 'u2', muted: false },
    ]);
    v.leave('c1', 'u1');
    expect(v.members('c1')).toEqual([{ userId: 'u2', muted: false }]);
    expect(v.members('c2')).toHaveLength(1);
    expect(v.members('desconocido')).toEqual([]);
  });

  it('setMuted flips the flag and implies presence; join keeps the mute', () => {
    const v = new VoiceStates();
    v.setMuted('c1', 'u1', true); // mute antes de que llegue el webhook de join
    expect(v.members('c1')).toEqual([{ userId: 'u1', muted: true }]);
    v.join('c1', 'u1'); // el join no resetea el mute
    expect(v.members('c1')).toEqual([{ userId: 'u1', muted: true }]);
    v.setMuted('c1', 'u1', false);
    expect(v.members('c1')).toEqual([{ userId: 'u1', muted: false }]);
  });

  it('clear empties a channel', () => {
    const v = new VoiceStates();
    v.join('c1', 'u1');
    v.clear('c1');
    expect(v.members('c1')).toEqual([]);
  });
});
