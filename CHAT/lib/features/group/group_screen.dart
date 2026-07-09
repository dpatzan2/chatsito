import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/community.dart';
import '../../domain/repositories/chat_repository.dart';
import '../chat/chat_controller.dart';
import 'call_controller.dart';
import 'group_controller.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.read<ChatController>();
    final call = context.watch<CallController>();
    final community = context.watch<ChatRepository>().activeCommunity;
    return Container(
      color: C.ink,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color.lerp(C.accent, Colors.black, .08)!, Color.lerp(C.accent, Colors.black, .36)!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _roundBtn(Icons.arrow_back_ios_new, () => context.read<GroupController>().back()),
                  const Spacer(),
                  _roundBtn(Icons.person_add_alt_1, () => context.read<GroupController>().openInvite()),
                ]),
                const SizedBox(height: 16),
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.groups, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(community?.name ?? 'Comunidad',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.3)),
                const SizedBox(height: 5),
                Text('${community?.members.length ?? 0} miembros',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .7))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 30),
              children: [
                _label('Canales de texto'),
                for (final ch in community?.textChannels ?? const <Channel>[]) _textChannel(context, chat, ch),
                _label('Canales de voz'),
                for (final ch in community?.voiceChannels ?? const <Channel>[]) _voiceChannel(context, call, ch),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
        child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF7E8190), letterSpacing: .6)),
      );

  Widget _textChannel(BuildContext context, ChatController chat, Channel ch) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => chat.openChannel(ch),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(children: [
          const Text('#', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF7E8190))),
          const SizedBox(width: 10),
          Expanded(child: Text(ch.name,
              style: TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w600,
                  color: ch.unread > 0 ? Colors.white : const Color(0xFFC7CAD3)))),
          if (ch.unread > 0)
            Container(
              constraints: const BoxConstraints(minWidth: 20),
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(10)),
              child: Text('${ch.unread}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
        ]),
      ),
    );
  }

  Widget _voiceChannel(BuildContext context, CallController call, Channel ch) {
    final members = call.membersOf(ch.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => call.openCall(ch),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.volume_up_outlined, size: 18, color: Color(0xFF7E8190)),
              const SizedBox(width: 10),
              Expanded(child: Text(ch.name, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: Color(0xFFC7CAD3)))),
              Text(members.isEmpty ? 'Vacío' : '${members.length} conectados',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF7E8190), fontWeight: FontWeight.w600)),
            ]),
            if (members.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 8, bottom: 2),
                child: Column(
                  children: [for (final m in members) Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(children: [
                      Container(
                        width: 26, height: 26, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: m.color, shape: BoxShape.circle,
                          border: m.speaking ? Border.all(color: const Color(0xFF1FD27A), width: 2) : null,
                        ),
                        child: Text(m.initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(width: 9),
                      Text(m.name, style: const TextStyle(fontSize: 13.5, color: Color(0xFFC7CAD3))),
                      if (m.muted) ...[const SizedBox(width: 6), const Icon(Icons.mic_off, size: 14, color: C.danger)],
                    ]),
                  )],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
