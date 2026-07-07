import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/message.dart';
import '../chat_controller.dart';

class _Option {
  final String label;
  final Color bg, fg;
  final IconData icon;
  final MessageType? sends;
  const _Option(this.label, this.bg, this.icon, this.fg, [this.sends]);
}

const _options = <_Option>[
  _Option('Cámara', Color(0xFFF1EEFF), Icons.photo_camera_outlined, C.accent),
  _Option('Galería', Color(0xFFE7F6F0), Icons.image_outlined, C.green, MessageType.image),
  _Option('Vídeo', Color(0xFFFDEEE9), Icons.videocam_outlined, Color(0xFFE76F51), MessageType.video),
  _Option('Documento', Color(0xFFEAF1FE), Icons.description_outlined, Color(0xFF2A6FDB), MessageType.doc),
  _Option('Audio', Color(0xFFFBEEF8), Icons.mic_none, Color(0xFFC13D9E)),
  _Option('Ubicación', Color(0xFFEAF6FE), Icons.location_on_outlined, Color(0xFF1F8AC0)),
  _Option('Contacto', Color(0xFFF0F0F4), Icons.person_outline, C.sub),
  _Option('Encuesta', Color(0xFFFEF6E7), Icons.bar_chart, Color(0xFFE0A000)),
];

class AttachSheet extends StatelessWidget {
  const AttachSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.read<ChatController>();
    return Stack(children: [
      Positioned.fill(child: GestureDetector(onTap: c.closeSheets, child: const SizedBox())),
      Positioned(
        left: 12, right: 12, bottom: 80,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Color(0x2E140E2D), blurRadius: 50, offset: Offset(0, 18))],
          ),
          child: GridView.count(
            crossAxisCount: 4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14, crossAxisSpacing: 8, childAspectRatio: .82,
            children: [for (final o in _options) GestureDetector(
              onTap: () => o.sends != null ? c.sendAttachment(o.sends!) : c.closeSheets(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: o.bg, borderRadius: BorderRadius.circular(18)),
                  child: Icon(o.icon, color: o.fg, size: 26),
                ),
                const SizedBox(height: 7),
                Text(o.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: C.sub)),
              ]),
            )],
          ),
        ),
      ),
    ]);
  }
}
