import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/community.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../l10n/app_localizations.dart';

/// Miembros agrupados por su rol más alto (estilo Discord); offline al final.
class MembersPanel extends StatelessWidget {
  const MembersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<ChatRepository>().activeCommunity;
    final t = S.of(context);
    if (community == null) return const SizedBox.shrink();

    // rol más alto = menor position entre los roles no-everyone del miembro
    final roles = [for (final r in community.roles) if (!r.isEveryone) r]
      ..sort((a, b) => a.position.compareTo(b.position));
    final byRole = <Role?, List<Member>>{};
    final offline = <Member>[];
    for (final m in community.members) {
      if (!m.online) { offline.add(m); continue; }
      Role? top;
      for (final r in roles) {
        if (m.roleIds.contains(r.id)) { top = r; break; }
      }
      (byRole[top] ??= []).add(m);
    }

    return Container(
      color: const Color(0xFF23252E),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
        children: [
          for (final r in roles)
            if (byRole[r] != null) ..._section(r.name, r.color ?? C.accent, byRole[r]!),
          if (byRole[null] != null) ..._section(t.membersOnline, const Color(0xFF7E8190), byRole[null]!),
          if (offline.isNotEmpty) ..._section(t.membersOffline, const Color(0xFF7E8190), offline, dim: true),
        ],
      ),
    );
  }

  List<Widget> _section(String title, Color color, List<Member> members, {bool dim = false}) => [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
          child: Text('${title.toUpperCase()} — ${members.length}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: .5)),
        ),
        for (final m in members)
          Opacity(
            opacity: dim ? .45 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: Row(children: [
                Container(
                  width: 30, height: 30, alignment: Alignment.center,
                  decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
                  child: Text(m.name.isEmpty ? '?' : m.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Color(0xFFC7CAD3)))),
                if (!dim) const CircleAvatar(radius: 4, backgroundColor: Color(0xFF1FD27A)),
              ]),
            ),
          ),
      ];
}
