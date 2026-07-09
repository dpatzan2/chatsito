import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/community.dart';
import '../../domain/repositories/chat_repository.dart';
import 'group_controller.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = context.read<GroupController>();
    final community = context.watch<ChatRepository>().activeCommunity;
    final roles = [...?community?.roles]..sort((a, b) => b.position.compareTo(a.position));
    return Container(
      color: C.ink,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 14, 6),
          child: Row(children: [
            IconButton(
                onPressed: gc.closeRoles,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white)),
            const Expanded(
                child: Text('Roles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
            IconButton(
                onPressed: () => gc.openRole(null),
                icon: const Icon(Icons.add, color: Colors.white)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
            children: [
              if (community != null)
                for (final r in roles) _row(gc, community, r),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _row(GroupController gc, Community community, Role r) {
    final count = r.isEveryone
        ? community.members.length
        : community.members.where((m) => m.roleIds.contains(r.id)).length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => gc.openRole(r),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: r.color ?? const Color(0xFF7E8190), shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(r.name,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w600, color: Color(0xFFC7CAD3)))),
          Text('$count', style: const TextStyle(fontSize: 13, color: Color(0xFF7E8190))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF7E8190)),
        ]),
      ),
    );
  }
}
