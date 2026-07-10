import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../l10n/app_localizations.dart';
import '../chat/chat_controller.dart';
import 'group_controller.dart';
import 'members_panel.dart';

class ChannelDetailScreen extends StatelessWidget {
  const ChannelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ChatRepository>();
    final community = repo.activeCommunity;
    final target = context.read<ChatController>().target;
    final t = S.of(context);
    return Container(
      color: const Color(0xFF1B1D24),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 30, 12, 6),
          child: Row(children: [
            IconButton(
                onPressed: () => context.read<ChatController>().backToChat(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white)),
            Expanded(child: Text(target?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
        ),
        Text(community?.name ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF7E8190))),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton.icon(
            onPressed: () => context.read<GroupController>().openInvite(),
            icon: const Icon(Icons.person_add_alt_1, size: 16, color: C.accent),
            label: Text(t.inviteCommunityTitle, style: const TextStyle(color: C.accent)),
          ),
        ]),
        const Expanded(child: MembersPanel()),
        SafeArea(
          top: false,
          child: TextButton(
            onPressed: () => _confirmLeave(context),
            child: Text(t.leaveCommunity,
                style: const TextStyle(color: C.danger, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  void _confirmLeave(BuildContext context) {
    final t = S.of(context);
    showDialog(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(t.leaveCommunity),
        content: Text(t.leaveCommunityConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog), child: Text(t.cancel)),
          TextButton(
            onPressed: () async {
              final repo = context.read<ChatRepository>();
              final router = context.read<AppRouter>();
              Navigator.pop(dialog);
              await repo.leaveCommunity();
              router.go(AppScreen.chats);
            },
            child: Text(t.leaveAction, style: const TextStyle(color: C.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
