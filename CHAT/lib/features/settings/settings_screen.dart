import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar.dart';
import '../../domain/repositories/auth_repository.dart';
import 'settings_controller.dart';

class _Item {
  final String key, label;
  final Color bg, fg;
  final IconData icon;
  const _Item(this.key, this.label, this.bg, this.icon, this.fg);
}

const _group1 = <_Item>[
  _Item('cuenta', 'Cuenta', Color(0xFFEAF1FE), Icons.person_outline, Color(0xFF2A6FDB)),
  _Item('privacidad', 'Privacidad', Color(0xFFE7F6F0), Icons.lock_outline, C.green),
  _Item('chats', 'Chats', Color(0xFFF1EEFF), Icons.chat_bubble_outline, C.accent),
  _Item('notif', 'Notificaciones', Color(0xFFFDEEE9), Icons.notifications_none, Color(0xFFE76F51)),
  _Item('storage', 'Almacenamiento y datos', Color(0xFFEAF6FE), Icons.storage_outlined, Color(0xFF1F8AC0)),
];
const _group2 = <_Item>[
  _Item('ayuda', 'Ayuda', Color(0xFFF0F0F4), Icons.help_outline, C.sub),
  _Item('invitar', 'Invitar a un amigo', Color(0xFFFEF6E7), Icons.person_add_alt, Color(0xFFE0A000)),
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepository>().user;
    final c = context.read<SettingsController>();
    final router = context.read<AppRouter>();

    return Container(
      color: C.field,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEFF2)))),
            padding: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
              child: Row(children: [
                IconButton(onPressed: () => router.go(AppScreen.chats), icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: C.accent)),
                const Text('Ajustes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Avatar(user.initials, C.accent, size: 64, fontSize: 22),
                    const SizedBox(width: 15),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: C.ink)),
                        const SizedBox(height: 2),
                        Text('+34 ${user.phoneFormatted}', style: const TextStyle(fontSize: 13.5, color: C.muted)),
                        const SizedBox(height: 5),
                        const Text('Disponible · ✓ verificado', style: TextStyle(fontSize: 13, color: C.accent, fontWeight: FontWeight.w600)),
                      ],
                    )),
                    const Icon(Icons.chevron_right, color: C.arrow, size: 22),
                  ]),
                ),
                const SizedBox(height: 16),
                _card(c, _group1),
                const SizedBox(height: 16),
                _card(c, _group2),
                const SizedBox(height: 22),
                const Center(child: Text('Chatsito · v1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFFB7BAC4)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(SettingsController c, List<_Item> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final it = items[i];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => it.key == 'invitar' ? c.openInvite() : c.openDetail(it.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(border: i == items.length - 1 ? null : const Border(bottom: BorderSide(color: C.hair))),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: it.bg, borderRadius: BorderRadius.circular(9)),
                  child: Icon(it.icon, size: 18, color: it.fg),
                ),
                const SizedBox(width: 13),
                Expanded(child: Text(it.label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: C.ink))),
                const Icon(Icons.chevron_right, size: 20, color: C.arrow),
              ]),
            ),
          );
        }),
      ),
    );
  }
}
