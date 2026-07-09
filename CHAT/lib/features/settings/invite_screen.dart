import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/repositories/auth_repository.dart';
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
              Text(communityInvite ? 'Invitar a la comunidad' : 'Invitar a un amigo',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
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
                Text(communityInvite ? 'Invita gente a la comunidad' : 'Invita a tu equipo a Chatsito',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.3)),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    communityInvite
                        ? 'Comparte este código: en Chatsito, "Unirme con código". Caduca en 7 días.'
                        : 'Comparte tu enlace personal. Cuando se unan, los verás en tus chats al instante.',
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
                        child: const Text('Copiar', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: C.accent)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 30),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  shareIcon(Icons.chat_bubble_outline, const Color(0xFFE7F6F0), C.green, 'Mensaje'),
                  const SizedBox(width: 30),
                  shareIcon(Icons.mail_outline, const Color(0xFFEAF1FE), const Color(0xFF2A6FDB), 'Correo'),
                  const SizedBox(width: 30),
                  shareIcon(Icons.more_horiz, const Color(0xFFF0F0F4), C.sub, 'Más'),
                ]),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
            child: PrimaryButton(communityInvite ? 'Listo' : 'Compartir enlace', back, height: 54),
          ),
        ],
      ),
    );
  }
}
