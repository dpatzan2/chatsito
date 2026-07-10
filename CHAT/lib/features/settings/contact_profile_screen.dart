import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_toggle.dart';
import '../../core/widgets/avatar.dart';
import '../../domain/models/chat_target.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../l10n/app_localizations.dart';
import '../chat/chat_controller.dart';
import 'settings_controller.dart';

class ContactProfileScreen extends StatelessWidget {
  const ContactProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.read<ChatController>();
    final settings = context.watch<SettingsController>();
    final t = chat.target ?? const ChatTarget(title: '', initials: '', subtitle: '', color: C.accent);
    final s = S.of(context);

    return Container(
      color: C.field,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 36),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.tint(80), Colors.white], stops: const [0, .72]),
                ),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                child: Column(children: [
                  Avatar(t.initials, t.color, size: 104, fontSize: 38),
                  const SizedBox(height: 16),
                  Text(t.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.3)),
                  const SizedBox(height: 5),
                  Text(t.phone == null ? '' : '+${formatPhone(t.phone!)}',
                      style: const TextStyle(fontSize: 15, color: C.sub)),
                  const SizedBox(height: 8),
                  Text(t.subtitle, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: C.green)),
                ]),
              ),
              Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    _Action(Icons.call_outlined, s.actionAudio),
                    _Action(Icons.videocam_outlined, s.actionVideo),
                    _Action(Icons.search, s.actionSearch),
                    _Action(Icons.notifications_off_outlined, s.actionMute),
                  ]),
                ),
              ),
              _section(margin: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.aboutHeader.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .4)),
                  const SizedBox(height: 8),
                  Text(s.aboutSample, style: const TextStyle(fontSize: 15.5, height: 1.45, color: C.ink)),
                ],
              )),
              _section(margin: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(s.mediaFiles, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: C.ink))),
                    Text(s.seeAll, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: C.accent)),
                  ]),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6, crossAxisSpacing: 6,
                    children: [
                      // ponytail: placeholder gris por imagen; Task 10 lo vuelve Image.network
                      for (final _ in context.watch<ChatRepository>().messages
                          .where((m) => m.type == MessageType.image))
                        const DecoratedBox(decoration: BoxDecoration(color: Color(0xFFD9DCE6), borderRadius: BorderRadius.all(Radius.circular(11)))),
                    ],
                  ),
                ],
              )),
              _section(margin: const EdgeInsets.fromLTRB(16, 16, 16, 0), padding: EdgeInsets.zero, child: Column(children: [
                // ponytail: silenciar es visual (deshabilitado); funcional en otra fase
                Opacity(
                  opacity: .4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.hair))),
                    child: Row(children: [
                      Expanded(child: Text(s.muteNotifications, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: C.ink))),
                      AppToggle(settings.isOn('contactMute'), () {}),
                    ]),
                  ),
                ),
                _navRow(s.tempMessages, s.disabled),
                _navRow(s.encryption, s.verified, last: true),
              ])),
              // ponytail: bloquear/reportar visual (deshabilitado); funcional en otra fase
              Opacity(
                opacity: .4,
                child: _section(margin: const EdgeInsets.fromLTRB(16, 16, 16, 0), padding: EdgeInsets.zero, child: Column(children: [
                  _dangerRow(Icons.block, s.blockContact(t.title)),
                  _dangerRow(Icons.flag_outlined, s.reportContact, last: true),
                ])),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock_outline, size: 13, color: C.faint),
                  const SizedBox(width: 6),
                  Flexible(child: Text(s.e2eNotice, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: C.faint))),
                ]),
              ),
            ],
          ),
          Positioned(
            top: 8, left: 0, right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _glassBtn(Icons.arrow_back_ios_new, chat.backToChat),
                _glassBtn(Icons.edit_outlined, () {}),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required Widget child, required EdgeInsets margin, EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
        margin: margin, padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: child,
      );

  Widget _navRow(String label, String detail, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.hair))),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: C.ink))),
          Text(detail, style: const TextStyle(fontSize: 14, color: C.muted)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: C.arrow),
        ]),
      );

  Widget _dangerRow(IconData icon, String label, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.hair))),
        child: Row(children: [
          Icon(icon, size: 20, color: C.danger),
          const SizedBox(width: 11),
          Text(label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.danger)),
        ]),
      );

  Widget _glassBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .7), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: C.accent),
        ),
      );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Action(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0D140E2D), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: C.accent),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: C.sub)),
        ]),
      ),
    );
  }
}
