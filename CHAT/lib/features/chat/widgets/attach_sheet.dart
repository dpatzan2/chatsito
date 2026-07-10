import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/message.dart';
import '../../../l10n/app_localizations.dart';
import '../chat_controller.dart';

class _Option {
  final String label;
  final Color bg, fg;
  final IconData icon;
  final MessageType? sends;
  const _Option(this.label, this.bg, this.icon, this.fg, [this.sends]);
}

class AttachSheet extends StatelessWidget {
  const AttachSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.read<ChatController>();
    final t = S.of(context);
    final options = <_Option>[
      _Option(t.attachCamera, const Color(0xFFF1EEFF), Icons.photo_camera_outlined, C.accent),
      _Option(t.attachGallery, const Color(0xFFE7F6F0), Icons.image_outlined, C.green, MessageType.image),
      _Option(t.attachVideo, const Color(0xFFFDEEE9), Icons.videocam_outlined, const Color(0xFFE76F51)),
      _Option(t.attachDocument, const Color(0xFFEAF1FE), Icons.description_outlined, const Color(0xFF2A6FDB), MessageType.doc),
      _Option(t.attachAudio, const Color(0xFFFBEEF8), Icons.mic_none, const Color(0xFFC13D9E)),
      _Option(t.attachLocation, const Color(0xFFEAF6FE), Icons.location_on_outlined, const Color(0xFF1F8AC0)),
      _Option(t.attachContact, const Color(0xFFF0F0F4), Icons.person_outline, C.sub),
      _Option(t.attachPoll, const Color(0xFFFEF6E7), Icons.bar_chart, const Color(0xFFE0A000)),
    ];
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
            children: [for (final o in options) GestureDetector(
              onTap: () => o.sends != null ? _pick(context, o.sends!) : c.closeSheets(),
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

  Future<void> _pick(BuildContext context, MessageType type) async {
    final chat = context.read<ChatController>();
    final t = S.of(context);
    final result = await FilePicker.pickFiles(
        type: type == MessageType.image ? FileType.image : FileType.any, withData: true);
    final f = result?.files.firstOrNull;
    if (f == null || f.bytes == null) return;
    try {
      await chat.sendFile(type, f.bytes!, f.name, _mimeOf(f));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.uploadError)));
      }
    }
  }

  String _mimeOf(PlatformFile f) => switch (f.extension?.toLowerCase()) {
        'png' => 'image/png', 'gif' => 'image/gif', 'webp' => 'image/webp',
        'jpg' || 'jpeg' => 'image/jpeg', 'pdf' => 'application/pdf',
        _ => 'application/octet-stream',
      };
}
