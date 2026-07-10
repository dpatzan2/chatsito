import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';
import 'settings_controller.dart';

class _Item {
  final String key, label;
  final Color bg, fg;
  final IconData icon;
  const _Item(this.key, this.label, this.bg, this.icon, this.fg);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepository>().user;
    final c = context.read<SettingsController>();
    final router = context.read<AppRouter>();
    final t = S.of(context);
    final group1 = <_Item>[
      _Item('cuenta', t.setAccount, const Color(0xFFEAF1FE), Icons.person_outline, const Color(0xFF2A6FDB)),
      _Item('privacidad', t.setPrivacy, const Color(0xFFE7F6F0), Icons.lock_outline, C.green),
      _Item('chats', t.setChats, const Color(0xFFF1EEFF), Icons.chat_bubble_outline, C.accent),
      _Item('notif', t.setNotifications, const Color(0xFFFDEEE9), Icons.notifications_none, const Color(0xFFE76F51)),
      _Item('storage', t.setStorage, const Color(0xFFEAF6FE), Icons.storage_outlined, const Color(0xFF1F8AC0)),
    ];
    final group2 = <_Item>[
      _Item('ayuda', t.setHelp, const Color(0xFFF0F0F4), Icons.help_outline, C.sub),
      _Item('invitar', t.setInvite, const Color(0xFFFEF6E7), Icons.person_add_alt, const Color(0xFFE0A000)),
    ];

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
                Text(t.settingsTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _editProfile(context),
                  child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Avatar(user.initials, C.accent, size: 64, fontSize: 22, imageUrl: user.avatarUrl),
                    const SizedBox(width: 15),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: C.ink)),
                        const SizedBox(height: 2),
                        Text('+${user.phoneFormatted}', style: const TextStyle(fontSize: 13.5, color: C.muted)),
                        const SizedBox(height: 5),
                        Text(t.availableVerified, style: const TextStyle(fontSize: 13, color: C.accent, fontWeight: FontWeight.w600)),
                      ],
                    )),
                    const Icon(Icons.chevron_right, color: C.arrow, size: 22),
                  ]),
                  ),
                ),
                const SizedBox(height: 16),
                _card(c, group1),
                const SizedBox(height: 16),
                _card(c, group2),
                const SizedBox(height: 16),
                _sessionCard(context, c, t),
                const SizedBox(height: 22),
                const Center(child: Text('Chatsito · v1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFFB7BAC4)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final t = S.of(context);
    final auth = context.read<AuthRepository>();
    final name = TextEditingController(text: auth.user.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.viewInsetsOf(sheet).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t.editProfileTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
          const SizedBox(height: 18),
          ListenableBuilder(
            listenable: auth,
            builder: (_, _) => Avatar(auth.user.initials, C.accent,
                size: 88, fontSize: 30, imageUrl: auth.user.avatarUrl),
          ),
          TextButton(
            onPressed: () async {
              final r = await FilePicker.pickFiles(type: FileType.image, withData: true);
              final f = r?.files.firstOrNull;
              if (f?.bytes == null) return;
              await auth.saveAvatar(f!.bytes!, f.name, 'image/${f.extension ?? 'jpeg'}');
            },
            child: Text(t.changePhoto, style: const TextStyle(fontWeight: FontWeight.w700, color: C.accent)),
          ),
          TextField(
            controller: name,
            decoration: InputDecoration(hintText: t.profileNameHint),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: C.accent),
              onPressed: () async {
                if (name.text.trim().isNotEmpty) await auth.saveName(name.text.trim());
                if (sheet.mounted) Navigator.pop(sheet);
              },
              child: Text(t.saveAction),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _sessionCard(BuildContext context, SettingsController c, S t) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _confirm(context, t.logoutAction, t.logoutConfirm, t.logoutAction, C.accent, c.logout),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.hair))),
              child: Row(children: [
                const Icon(Icons.logout, size: 20, color: C.accent),
                const SizedBox(width: 11),
                Text(t.logoutAction, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.accent)),
              ]),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _confirm(context, t.catDeleteAccount, t.deleteAccountWarning, t.deleteAction, C.danger, c.deleteAccount),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Icon(Icons.delete_outline, size: 20, color: C.danger),
                const SizedBox(width: 11),
                Text(t.catDeleteAccount, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.danger)),
              ]),
            ),
          ),
        ]),
      );

  void _confirm(BuildContext context, String title, String message, String action,
      Color color, Future<void> Function() onConfirm) {
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () { Navigator.pop(dialog); onConfirm(); },
            child: Text(action, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
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
