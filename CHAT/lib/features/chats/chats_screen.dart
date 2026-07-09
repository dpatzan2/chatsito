import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../chat/chat_controller.dart';
import '../group/group_controller.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = context.watch<ChatRepository>().conversations;
    final initials = context.watch<AuthRepository>().user.initials;
    final router = context.read<AppRouter>();

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chats', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.5)),
                        GestureDetector(
                          onTap: () => router.go(AppScreen.settings),
                          child: Container(
                            width: 42, height: 42, alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Color(0xFFF1EEFF), shape: BoxShape.circle),
                            child: Text(initials, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: C.accent)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 42, padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(13)),
                      child: const Row(children: [
                        Icon(Icons.search, size: 18, color: C.muted),
                        SizedBox(width: 9),
                        Text('Buscar', style: TextStyle(fontSize: 15, color: C.muted)),
                      ]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 4, bottom: 90),
                  children: [for (final c in conversations) _ConvoRow(c)],
                ),
              ),
            ],
          ),
          Positioned(
            right: 20, bottom: 96,
            child: GestureDetector(
              onTap: () => _openNewMenu(context),
              child: Container(
                width: 58, height: 58,
                decoration: BoxDecoration(
                  color: C.accent, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: C.aOpacity(60), blurRadius: 28, offset: const Offset(0, 14))],
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 26),
              ),
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: _BottomNav()),
        ],
      ),
    );
  }
}

void _openNewMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheet) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline, color: C.accent),
          title: const Text('Nuevo chat', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () { Navigator.pop(sheet); _askStartChat(context); },
        ),
        ListTile(
          leading: const Icon(Icons.groups_outlined, color: C.accent),
          title: const Text('Nueva comunidad', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () { Navigator.pop(sheet); context.read<GroupController>().openCreate(); },
        ),
        ListTile(
          leading: const Icon(Icons.key_outlined, color: C.accent),
          title: const Text('Unirme con código', style: TextStyle(fontWeight: FontWeight.w600)),
          onTap: () { Navigator.pop(sheet); _askJoinCode(context); },
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );
}

void _askStartChat(BuildContext context) {
  final chat = context.read<ChatController>();
  _askInput(
    context,
    title: 'Nuevo chat',
    hint: 'Teléfono (solo dígitos)',
    action: 'Abrir chat',
    keyboard: TextInputType.phone,
    onSubmit: (v) async =>
        await chat.startChat(v) ? null : 'No hay ningún usuario con ese número',
  );
}

void _askJoinCode(BuildContext context) {
  final chat = context.read<ChatController>();
  _askInput(
    context,
    title: 'Unirme a una comunidad',
    hint: 'Código de invitación',
    action: 'Unirme',
    keyboard: TextInputType.text,
    onSubmit: (v) async =>
        await chat.joinInvite(v) ? null : 'Código inválido o caducado',
  );
}

/// Dialog con un TextField; [onSubmit] devuelve null si fue bien o el error a mostrar.
void _askInput(BuildContext context,
    {required String title, required String hint, required String action,
    required TextInputType keyboard, required Future<String?> Function(String) onSubmit}) {
  final field = TextEditingController();
  String? error;
  bool busy = false;
  showDialog(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setState) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink)),
        content: TextField(
          controller: field, autofocus: true, keyboardType: keyboard,
          decoration: InputDecoration(hintText: hint, errorText: error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancelar')),
          TextButton(
            onPressed: busy ? null : () async {
              if (field.text.trim().isEmpty) return;
              setState(() => busy = true);
              final err = await onSubmit(field.text.trim());
              if (!dialog.mounted) return;
              if (err == null) {
                Navigator.pop(dialog);
              } else {
                setState(() { error = err; busy = false; });
              }
            },
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700, color: C.accent)),
          ),
        ],
      ),
    ),
  );
}

class _ConvoRow extends StatelessWidget {
  final Conversation c;
  const _ConvoRow(this.c);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<ChatController>().openConversation(c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        child: Row(
          children: [
            Avatar(c.initials, c.color,
              badge: c.isGroup
                  ? Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Icon(Icons.groups, size: 13, color: c.color),
                    )
                  : null),
            const SizedBox(width: 13),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 13),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.hair))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.ink))),
                      const SizedBox(width: 8),
                      Text(c.time, style: TextStyle(fontSize: 12, color: c.hasUnread ? C.accent : C.muted, fontWeight: c.hasUnread ? FontWeight.w700 : FontWeight.w500)),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      Expanded(child: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: C.muted))),
                      if (c.hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          height: 20, padding: const EdgeInsets.symmetric(horizontal: 6), alignment: Alignment.center,
                          decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(10)),
                          child: Text('${c.unread}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final router = context.read<AppRouter>();
    Widget item(IconData icon, String label, bool active, VoidCallback? onTap) => Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 24, color: active ? C.accent : const Color(0xFFA8AAB4)),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w700 : FontWeight.w600, color: active ? C.accent : const Color(0xFFA8AAB4))),
        ]),
      ),
    );
    return Container(
      height: 84,
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xEBFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFEEEFF2))),
      ),
      child: Row(children: [
        item(Icons.chat_bubble, 'Chats', true, null),
        item(Icons.groups_outlined, 'Grupos', false, () => context.read<GroupController>().openCreate()),
        item(Icons.call_outlined, 'Llamadas', false, null),
        item(Icons.settings_outlined, 'Ajustes', false, () => router.go(AppScreen.settings)),
      ]),
    );
  }
}
