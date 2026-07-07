import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = message;
    final isMe = m.isMine;
    final isSticker = m.type == MessageType.sticker;
    final radius = isMe
        ? const BorderRadius.only(topLeft: Radius.circular(kBubbleRadius), topRight: Radius.circular(kBubbleRadius), bottomLeft: Radius.circular(kBubbleRadius), bottomRight: Radius.circular(5))
        : const BorderRadius.only(topLeft: Radius.circular(kBubbleRadius), topRight: Radius.circular(kBubbleRadius), bottomRight: Radius.circular(kBubbleRadius), bottomLeft: Radius.circular(5));
    final metaColor = isMe ? Colors.white.withValues(alpha: .72) : C.faint;
    final isMedia = m.type == MessageType.image || m.type == MessageType.video;

    final pad = isSticker
        ? EdgeInsets.zero
        : isMedia ? const EdgeInsets.all(5) : const EdgeInsets.fromLTRB(12, 8, 12, 6);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 8),
        padding: pad,
        decoration: BoxDecoration(
          color: isSticker ? Colors.transparent : (isMe ? C.accent : Colors.white),
          borderRadius: isSticker ? BorderRadius.circular(8) : radius,
          boxShadow: (isMe || isSticker) ? null : const [BoxShadow(color: Color(0x0F140E2D), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _content(isMe),
            Padding(
              padding: EdgeInsets.only(top: (isMedia || isSticker) ? 4 : 2),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(m.time ?? '', style: TextStyle(fontSize: 10.5, color: metaColor)),
                if (isMe) ...[const SizedBox(width: 4), Icon(Icons.done_all, size: 14, color: metaColor)],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(bool isMe) {
    switch (message.type) {
      case MessageType.image:
        return _media(icon: null, label: 'IMG · foto.jpg');
      case MessageType.video:
        return _media(icon: Icons.play_arrow, label: '0:42');
      case MessageType.doc:
        return _doc(isMe);
      case MessageType.sticker:
        return Text(message.sticker ?? '', style: const TextStyle(fontSize: 78, height: 1));
      case MessageType.text:
        return Text(message.text ?? '', style: TextStyle(fontSize: 15, height: 1.4, color: isMe ? Colors.white : C.ink));
    }
  }

  Widget _media({IconData? icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200, height: 148, color: const Color(0xFFCFD3DF),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (icon != null)
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: .6), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            Positioned(
              bottom: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(5)),
                child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'monospace')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doc(bool isMe) {
    return SizedBox(
      width: 208,
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: isMe ? Colors.white.withValues(alpha: .22) : C.tint(86), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.description_outlined, size: 20, color: isMe ? Colors.white : C.accent),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.docName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isMe ? Colors.white : C.ink)),
              const SizedBox(height: 2),
              Text(message.docSize ?? '', style: TextStyle(fontSize: 12, color: (isMe ? Colors.white : C.ink).withValues(alpha: .7))),
            ],
          ),
        ),
      ]),
    );
  }
}
