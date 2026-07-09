import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../l10n/app_localizations.dart';
import '../group/group_controller.dart';
import 'settings_controller.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SettingsController>();
    final gc = context.watch<GroupController>();
    // con código de comunidad la pantalla invita a la comunidad activa;
    // sin él, mantiene el enlace personal de siempre
    final communityInvite = gc.inviteCode.isNotEmpty;
    final code = communityInvite ? gc.inviteCode : context.watch<AuthRepository>().user.inviteCode;
    final back = gc.closeInvite;
    final t = S.of(context);

    Widget shareIcon(IconData icon, Color bg, Color fg, String label) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: fg, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.sub)),
      ],
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            child: Row(children: [
              IconButton(onPressed: back, icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: C.accent)),
              Expanded(child: Text(communityInvite ? t.inviteCommunityTitle : t.inviteFriendTitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink))),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
              child: Column(children: [
                Container(
                  width: 96, height: 96, margin: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(color: C.tint(84), borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.person_add_alt_1_outlined, color: C.accent, size: 44),
                ),
                const SizedBox(height: 6),
                Text(communityInvite ? t.inviteCommunityHeading : t.inviteFriendHeading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.3)),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    communityInvite ? t.inviteCommunityCopy : t.inviteFriendCopy,
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, height: 1.5, color: C.sub)),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4D6DE), width: 1.5),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(communityInvite ? code : 'chatsito.app/i/$code', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink))),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Clipboard.setData(ClipboardData(text: code)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: C.tint(86), borderRadius: BorderRadius.circular(10)),
                        child: Text(t.copyAction, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: C.accent)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Flexible(child: shareIcon(Icons.chat_bubble_outline, const Color(0xFFE7F6F0), C.green, t.shareMessage)),
                  Flexible(child: shareIcon(Icons.mail_outline, const Color(0xFFEAF1FE), const Color(0xFF2A6FDB), t.shareEmail)),
                  Flexible(child: shareIcon(Icons.more_horiz, const Color(0xFFF0F0F4), C.sub, t.shareMore)),
                ]),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
            child: PrimaryButton(communityInvite ? t.done : t.shareLink, back, height: 54),
          ),
        ],
      ),
    );
  }
}
