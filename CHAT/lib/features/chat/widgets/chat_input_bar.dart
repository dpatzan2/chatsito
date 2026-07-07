import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../chat_controller.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController draft;
  const ChatInputBar(this.draft, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChatController>();
    return Container(
      decoration: const BoxDecoration(color: Color(0xF5FFFFFF), border: Border(top: BorderSide(color: C.line))),
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _circle(Icons.add, const Color(0xFFF1F1F4), C.sub, c.toggleAttach),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(color: C.field, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.only(left: 16, right: 6),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: draft,
                    onChanged: c.setDraft,
                    onSubmitted: (_) => c.send(),
                    textInputAction: TextInputAction.send,
                    style: const TextStyle(fontSize: 15, color: C.ink),
                    decoration: const InputDecoration(
                      hintText: 'Mensaje', hintStyle: TextStyle(color: C.muted),
                      border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: c.toggleEmoji,
                  icon: const Icon(Icons.emoji_emotions_outlined, size: 22, color: C.muted),
                  padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: c.send,
            child: Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
              child: Icon(c.hasDraft ? Icons.send : Icons.mic_none, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(IconData icon, Color bg, Color fg, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 22, color: fg),
        ),
      );
}
