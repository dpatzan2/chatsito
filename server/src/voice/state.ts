export interface VoiceMember {
  userId: string;
  muted: boolean;
}

// ponytail: estado efímero en memoria, un solo nodo; Redis si hay varias instancias
export class VoiceStates {
  private rooms = new Map<string, Map<string, VoiceMember>>();

  private room(channelId: string): Map<string, VoiceMember> {
    let room = this.rooms.get(channelId);
    if (!room) this.rooms.set(channelId, (room = new Map()));
    return room;
  }

  join(channelId: string, userId: string): void {
    const room = this.room(channelId);
    if (!room.has(userId)) room.set(userId, { userId, muted: false });
  }

  leave(channelId: string, userId: string): void {
    const room = this.rooms.get(channelId);
    room?.delete(userId);
    if (room?.size === 0) this.rooms.delete(channelId);
  }

  setMuted(channelId: string, userId: string, muted: boolean): void {
    const room = this.room(channelId);
    const member = room.get(userId) ?? { userId, muted };
    member.muted = muted;
    room.set(userId, member);
  }

  clear(channelId: string): void {
    this.rooms.delete(channelId);
  }

  members(channelId: string): VoiceMember[] {
    return [...(this.rooms.get(channelId)?.values() ?? [])];
  }
}
