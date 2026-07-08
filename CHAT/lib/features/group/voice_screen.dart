import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/channels.dart';
import '../../domain/repositories/chat_repository.dart';
import 'call_controller.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallController>();
    final community = context.watch<ChatRepository>().activeCommunity;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color.lerp(C.accent, Colors.black, .18)!, const Color(0xFF0E0D16)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF1FD27A), shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text('# ${call.channelName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
              const SizedBox(height: 14),
              Text(
                call.connecting
                    ? 'Conectando…'
                    : 'Canal de voz · ${community?.name ?? ''}',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .55)),
              ),
            ]),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 18, runSpacing: 18, alignment: WrapAlignment.center,
                  children: [for (final p in call.callParticipants) _person(p)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _control(call.muted ? Icons.mic_off : Icons.mic_none, call.muted ? C.danger : Colors.white.withValues(alpha: .14), call.toggleMute),
                const SizedBox(width: 18),
                _control(Icons.videocam_outlined, Colors.white.withValues(alpha: .14), () {}),
                const SizedBox(width: 18),
                _control(Icons.volume_up_outlined, Colors.white.withValues(alpha: .14), () {}),
                const SizedBox(width: 18),
                _control(Icons.call_end, C.danger, call.leave, shadow: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _person(VoiceMember p) {
    return SizedBox(
      width: 110,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 84, height: 84, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.color, shape: BoxShape.circle,
            border: p.speaking ? Border.all(color: const Color(0xFF1FD27A), width: 3) : null,
          ),
          child: Text(p.initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
          if (p.muted) ...[const SizedBox(width: 5), const Icon(Icons.mic_off, size: 14, color: C.danger)],
        ]),
      ]),
    );
  }

  Widget _control(IconData icon, Color bg, VoidCallback onTap, {bool shadow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: bg, shape: BoxShape.circle,
          boxShadow: shadow ? const [BoxShadow(color: Color(0x73E5484D), blurRadius: 24, offset: Offset(0, 10))] : null,
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}
