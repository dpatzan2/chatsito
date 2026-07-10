import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'chat_controller.dart';
import 'widgets/attach_sheet.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/emoji_sticker_sheet.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _draft = TextEditingController();
  final _scroll = ScrollController();
  late final ChatController _c;

  @override
  void initState() {
    super.initState();
    _c = context.read<ChatController>();
    _draft.text = _c.draft;
    _c.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  @override
  void dispose() {
    _c.removeListener(_sync);
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sync() {
    if (_draft.text != _c.draft) {
      _draft.value = TextEditingValue(text: _c.draft, selection: TextSelection.collapsed(offset: _c.draft.length));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _toBottom());
  }

  void _toBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChatController>();
    return Container(
      color: C.field,
      child: Stack(
        children: [
          Column(
            children: [
              _Header(),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(color: C.aOpacity(90), borderRadius: BorderRadius.circular(11)),
                        child: Text(S.of(context).today, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: C.accent)),
                      ),
                    ),
                    for (final m in c.messages) MessageBubble(m),
                  ],
                ),
              ),
              ChatInputBar(_draft),
            ],
          ),
          if (c.attachOpen) const AttachSheet(),
          if (c.emojiOpen) const EmojiStickerSheet(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChatController>();
    final t = c.target;
    return Container(
      decoration: const BoxDecoration(color: Color(0xF0FFFFFF), border: Border(bottom: BorderSide(color: C.line))),
      padding: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 14, 12),
        child: Row(
          children: [
            IconButton(onPressed: c.backToChats, icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: C.accent)),
            Expanded(
              child: GestureDetector(
                onTap: c.openDetails,
                child: Row(children: [
                  Container(
                    width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(color: t?.color ?? C.accent, shape: BoxShape.circle),
                    child: Text(t?.initials ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.ink)),
                        Text(c.peerTyping ? S.of(context).typing : t?.subtitle ?? '',
                            style: const TextStyle(fontSize: 12, color: C.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const Icon(Icons.call_outlined, size: 22, color: C.ink),
            const SizedBox(width: 14),
            const Icon(Icons.videocam_outlined, size: 24, color: C.ink),
          ],
        ),
      ),
    );
  }
}
